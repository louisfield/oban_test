defmodule ObanTest do
  @moduledoc """
  Documentation for `ObanTest`.
  """

  alias Oban.Pro.Workflow

  alias ObanTest.TestWorker

  def test_oban_scheduled() do
    workflow =
      Workflow.new()
      |> Workflow.add(:a, TestWorker.new(%{}))
      |> Workflow.add(:b, TestWorker.new(%{}), deps: [:a])
      |> Workflow.add(:loop_start, TestWorker.new(%{}), deps: [:b])

    ids = Enum.map(1..50000, &String.to_atom("loop-#{&1}"))

    ids
    |> Enum.reduce(workflow, fn val, acc ->
      Workflow.add(acc, val, TestWorker.new(%{}), deps: [:loop_start])
    end)
    |> Workflow.add(:loop_end, TestWorker.new(%{}), deps: ids)
    |> Oban.insert_all()
  end

  def test_oban_scheduled_no_loop_start_deps() do
    Workflow.new()
    |> Workflow.add(:a, TestWorker.new(%{}))
    |> Workflow.add(:b, TestWorker.new(%{}), deps: [:a])
    |> Workflow.add(:loop_start, TestWorker.new(%{run_loop: true}), deps: [:b])
    |> Oban.insert_all()
  end

  @spec test_oban_scheduled_with_graft_v2() :: [Oban.Job.t()] | Ecto.Multi.t()
  def test_oban_scheduled_with_graft_v2() do
    Workflow.new()
    |> Workflow.add(:a, TestWorker.new(%{}))
    |> Workflow.add(:b, TestWorker.new(%{}), deps: [:a])
    |> Workflow.add_graft(:loop_start, TestWorker.new(%{run_loop_2: true}), deps: [:b])
    |> Workflow.add(:loop_end, TestWorker.new(%{}), deps: [:loop_start])
    |> Oban.insert_all()
  end

  @spec test_oban_scheduled_with_graft_v3() :: [Oban.Job.t()] | Ecto.Multi.t()
  def test_oban_scheduled_with_graft_v3() do
    Workflow.new()
    |> Workflow.add(:a, TestWorker.new(%{}))
    |> Workflow.add(:b, TestWorker.new(%{}), deps: [:a])
    |> Workflow.add_graft(:loop_start, TestWorker.new(%{run_loop_3: true}), deps: [:b])
    |> Workflow.add(:loop_end, TestWorker.new(%{}), deps: [:loop_start])
    |> Oban.insert_all()
  end

  @spec test_oban_scheduled_with_graft_v4() :: [Oban.Job.t()] | Ecto.Multi.t()
  def test_oban_scheduled_with_graft_v4() do
    Workflow.new()
    |> Workflow.add(:a, TestWorker.new(%{}))
    |> Workflow.add(:b, TestWorker.new(%{}), deps: [:a])
    |> Workflow.add_graft(:loop_start, TestWorker.new(%{run_loop_4: true}), deps: [:b])
    |> Workflow.add(:loop_end, TestWorker.new(%{}), deps: [:loop_start])
    |> Oban.insert_all()
  end

  def test_oban_scheduled_retry() do
    workflow =
      Workflow.new()
      |> Workflow.add(:a, TestWorker.new(%{retry: true}))
      |> Workflow.add(:b, TestWorker.new(%{retry: true}), deps: [:a])
      |> Workflow.add(:loop_start, TestWorker.new(%{retry: true}), deps: [:b])

    ids = Enum.map(1..50000, &String.to_atom("loop-#{&1}"))

    ids
    |> Enum.reduce(workflow, fn val, acc ->
      Workflow.add(acc, val, TestWorker.new(%{retry: true}), deps: [:loop_start])
    end)
    |> Workflow.add(:loop_end, TestWorker.new(%{retry: true}), deps: ids)
    |> Oban.insert_all()
  end

  def test_oban_scheduled_with_graft() do
    ids = Enum.map(1..20000, &String.to_atom("loop-#{&1}"))

    Workflow.new()
    |> Workflow.add(:a, TestWorker.new(%{}))
    |> Workflow.add(:b, TestWorker.new(%{}), deps: [:a])
    |> Workflow.add(:loop_start, TestWorker.new(%{}), deps: [:b])
    |> Workflow.add_graft(:loop, {ids, &run_loop_item/2})
    |> Workflow.add(:loop_end, TestWorker.new(%{}), deps: [:loop])
    |> Oban.insert_all()
  end

  defp run_loop_item(id, _context) do
    {id, &process/2}
    |> Workflow.apply_graft()
    |> Oban.insert_all()

    :ok
  end

  defp process(a, b) do
    IO.inspect(a)
    IO.inspect(b)
    Process.sleep(2)

    {:ok, "hello"}
  end
end
