defmodule AccountService.Application do
  use Application

  alias AccountService.{Broker, Repo, Router}

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: 15000]},
      Broker,
      Repo
    ]

    opts = [strategy: :one_for_one, name: AccountService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
