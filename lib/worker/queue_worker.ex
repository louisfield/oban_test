defmodule ObanTest.QueueWorker do
  use Oban.Pro.Worker, queue: :insert_queue, max_attempts: 1

  alias Oban.Pro.Workflow

  alias ObanTest.TestWorker

  def process(%Job{args: %{"do_bundle" => true}}) do
    1..70
    |> Enum.reduce(Workflow.new(), fn val, acc ->
      deps = if val == 1, do: [], else: ["bundle-#{val - 1}"]
      Workflow.add(acc, "bundle-#{val}", TestWorker.new(%{}), deps: deps)
    end)
    |> Workflow.apply_graft()
    |> Oban.insert_all()

    {:ok, "hello"}
  end

  def process(%Job{args: %{"do_bundle_loop" => true}}) do
    1..70
    |> Enum.reduce(Workflow.new(), fn val, acc ->
      deps = if val == 1, do: [], else: ["bundle-#{val - 1}"]
      Workflow.add_graft(acc, "bundle-#{val}", TestWorker.new(%{run_loop: true}), deps: deps)
    end)
    |> Workflow.apply_graft()
    |> Oban.insert_all()

    {:ok, "hello"}
  end

  def backoff(_job) do
    1
  end
end
