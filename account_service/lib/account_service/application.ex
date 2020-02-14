defmodule AccountService.Application do
  use Application

  alias AccountService.{Broker, Repo}

  def start(_type, _args) do
    children = [
      Broker,
      Repo
    ]

    opts = [strategy: :one_for_one, name: AccountService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
