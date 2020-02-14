# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :api_gateway,
  ecto_repos: [ApiGateway.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :api_gateway, ApiGatewayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4lQfUKlNMp+d6nnD32YVLjYJcSXow/71U/VWQdr+uqQ7igy6L6UW9nhxElkvND78",
  render_errors: [view: ApiGatewayWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ApiGateway.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "P29mrNMC"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
