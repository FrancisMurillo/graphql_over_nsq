import Config

config :conduit, Conduit.Encoding, [
  {"json", Absinthe.Conduit.Json}
]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix,
  json_library: Jason,
  plug_init_mode: :runtime,
  stacktrace_depth: 20

config :api_gateway, ApiGateway.Broker,
  adapter: ConduitNSQ,
  producer_nsqds: [System.get_env("NSQ_HOST", "localhost:14150")],
  nsqds: [System.get_env("NSQ_HOST", "localhost:14150")]

config :api_gateway, ApiGatewayWeb.Endpoint,
  http: [port: 14000],
  url: [host: "0.0.0.0", port: 14000],
  secret_key_base: "4lQfUKlNMp+d6nnD32YVLjYJcSXow/71U/VWQdr+uqQ7igy6L6UW9nhxElkvND78",
  render_errors: [view: ApiGatewayWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ApiGateway.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "P29mrNMC"],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []
