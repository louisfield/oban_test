defmodule ObanTest.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ObanTest.Repo,
      {Oban, Application.fetch_env!(:oban_test, Oban)}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ObanTest.Supervisor)
  end
end
