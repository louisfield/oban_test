import Config

config :oban_test,
  ecto_repos: [ObanTest.Repo]

config :oban_test, ObanTest.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: System.get_env("POSTGRES_DB"),
  hostname: System.get_env("POSTGRES_HOST"),
  port: System.get_env("POSTGRES_PORT"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 20,
  # Let requests wait a bit longer in the queue before raising
  queue_target: 50,
  queue_interval: 1000

config :oban_test, Oban,
  engine: Oban.Pro.Engines.Smart,
  repo: ObanTest.Repo,
  plugins: [
    Oban.Pro.Plugins.DynamicLifeline
  ],
  queues: [
    my_queue: [
      local_limit: 20,
      global_limit: [
        allowed: 4,
        burst: true,
        partition: [
          fields: [:args],
          keys: [:global_id]
        ]
      ]
    ]
  ]
