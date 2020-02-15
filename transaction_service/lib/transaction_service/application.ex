defmodule TransactionService.Application do
  use Application

  alias TransactionService.{Broker, ProductClient, Repo}

  def start(_type, _args) do
    children = [
      Broker,
      ProductClient,
      Repo
    ]

    opts = [strategy: :one_for_one, name: TransactionService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
