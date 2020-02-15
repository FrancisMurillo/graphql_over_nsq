defmodule ApiGateway.Application do
  use Application

  alias ApiGateway.{Broker, AccountClient, ProductClient}
  alias ApiGatewayWeb.{Endpoint}

  def start(_type, _args) do
    children = [
      Broker,
      Endpoint,
      AccountClient,
      ProductClient
    ]

    opts = [strategy: :one_for_one, name: ApiGateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ApiGatewayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
