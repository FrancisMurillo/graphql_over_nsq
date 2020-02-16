defmodule TransactionService.Application do
  use Application

  alias TransactionService.{Broker, ProductClient, Repo, Router}

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: 17000]},
      Broker,
      ProductClient,
      Repo
    ]

    opts = [strategy: :one_for_one, name: TransactionService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
