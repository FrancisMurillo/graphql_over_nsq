import Config

config :absinthe,
  adapter: Absinthe.Adapter.Passthrough

config :conduit, Conduit.Encoding, [
  {"json", Absinthe.Conduit.Json}
]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :transaction_service, ecto_repos: [TransactionService.Repo]

config :transaction_service, TransactionService.Repo,
  username: System.get_env("DB_USER", "mq_user"),
  password: System.get_env("DB_PASSWORD", "mq_pass"),
  database: System.get_env("DB_NAME", "mq_db"),
  hostname: System.get_env("DB_HOST", "localhost"),
  port: System.get_env("DB_PORT", "5432") |> String.to_integer(),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log: false

config :transaction_service, TransactionService.Broker,
  adapter: ConduitNSQ,
  producer_nsqds: [System.get_env("NSQ_HOST", "localhost:14150")],
  nsqds: [System.get_env("NSQ_HOST", "localhost:14150")]
