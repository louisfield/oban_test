defmodule ObanTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :oban_test,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ObanTest.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oban_pro, "~> 1.6.0", repo: "oban"},
      {:oban_web, "~> 2.11"},
      {:oban, "~> 2.20"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_psql_extras, "~> 0.8"},
      {:ecto_sql, "~> 3.11.0"},
      {:igniter, "~> 0.6", only: [:dev, :test]}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
