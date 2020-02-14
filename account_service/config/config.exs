import Config

config :conduit, Conduit.Encoding, [
  {"json", Json}
]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :account_service, ecto_repos: [AccountService.Repo]

config :account_service, AccountService.Repo,
  username: System.get_env("DB_USER", "mq_user"),
  password: System.get_env("DB_PASSWORD", "mq_pass"),
  database: System.get_env("DB_NAME", "mq_db"),
  hostname: System.get_env("DB_HOST", "localhost"),
  port: System.get_env("DB_PORT", "5432") |> String.to_integer(),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log: false

config :account_service, AccountService.Broker,
  adapter: ConduitNSQ,
  producer_nsqds: [System.get_env("NSQ_HOST", "localhost:14150")],
  nsqds: [System.get_env("NSQ_HOST", "localhost:14150")]
