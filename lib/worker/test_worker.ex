defmodule ObanTest.TestWorker do
  use Oban.Pro.Worker, queue: :my_queue, max_attempts: 10

  alias Oban.Pro.Workflow

  alias ObanTest.{TestWorker, QueueWorker}

  @impl Oban.Pro.Worker
  @spec process(Job.t()) :: :retryable
  def process(%Job{args: %{"run_loop_2" => true}}) do
    ids = Enum.map(1..20000, &String.to_atom("loop-#{&1}"))

    workflow =
      ids
      |> Enum.reduce(Workflow.new(), fn val, acc ->
        Workflow.add(acc, val, TestWorker.new(%{}))
      end)

    workflow
    |> Workflow.apply_graft()
    |> Oban.insert_all()

    {:ok, "hello"}
  end

  def process(%Job{args: %{"run_loop" => true}}) do
    ids = Enum.map(1..40, &String.to_atom("loop-#{&1}"))

    workflow =
      ids
      |> Enum.reduce(Workflow.new(), fn val, acc ->
        Workflow.add(acc, val, TestWorker.new(%{}))
      end)

    workflow
    |> Workflow.apply_graft()
    |> Oban.insert_all()

    {:ok, "hello"}
  end

  def process(%Job{args: %{"run_loop_3" => true}}) do
    ids = Enum.map(1..400, &String.to_atom("loop-#{&1}"))

    workflow =
      ids
      |> Enum.reduce(Workflow.new(), fn val, acc ->
        acc
        |> Workflow.add_graft("loop-bundle-#{val}", QueueWorker.new(%{do_bundle: true}))
      end)

    workflow
    |> Workflow.apply_graft()
    |> Oban.insert_all()

    {:ok, "hello"}
  end

  def process(%Job{args: %{"run_loop_4" => true}}) do
    ids = Enum.map(1..400, &String.to_atom("loop-#{&1}"))

    workflow =
      ids
      |> Enum.reduce(Workflow.new(), fn val, acc ->
        acc
        |> Workflow.add_graft("loop-bundle-#{val}", QueueWorker.new(%{do_bundle_loop: true}))
      end)

    workflow
    |> Workflow.apply_graft()
    |> Oban.insert_all()

    {:ok, "hello"}
  end

  def process(%Job{args: args} = job) do
    retry? = Map.get(args, "retry", false)
    run_loop? = Map.get(args, "run_loop", false)
    if run_loop?, do: run_loop(job)

    Process.sleep(200)

    if retry?, do: {:error, "Something went wrong"}, else: {:ok, "hello"}
  end

  def backoff(_job) do
    1
  end

  defp run_loop(job) do
    # ids = Enum.map(1..20000, &String.to_atom("loop-#{&1}"))
    ids = Enum.map(1..5000, &String.to_atom("loop-#{&1}"))

    workflow = Workflow.append(job, check_deps: false)

    ids
    |> Enum.reduce(workflow, fn val, acc ->
      Workflow.add(acc, val, TestWorker.new(%{}))
    end)
    |> Workflow.add(:loop_end, TestWorker.new(%{}), deps: ids)
    |> Oban.insert_all()
  end
end
