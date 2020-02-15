defmodule ProductService.Application do
  @moduledoc false

  use Application

  alias ProductService.{Broker, Repo}

  def start(_type, _args) do
    children = [
      Broker,
      Repo
    ]

    opts = [strategy: :one_for_one, name: ProductService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
