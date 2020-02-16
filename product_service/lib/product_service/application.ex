defmodule ProductService.Application do
  @moduledoc false

  use Application

  alias ProductService.{Broker, Repo, Router}

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: 16000]},
      Broker,
      Repo
    ]

    opts = [strategy: :one_for_one, name: ProductService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
