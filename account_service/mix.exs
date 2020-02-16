defmodule AccountService.MixProject do
  use Mix.Project

  def project do
    [
      app: :account_service,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AccountService.Application, []}
    ]
  end

  defp deps do
    [
      {:uuid, "~> 1.1.8", app: false, runtime: false, override: true},
      {:ecto, "~> 3.3.2"},
      {:ecto_sql, "~> 3.3.2"},
      {:postgrex, "~> 0.15.3"},
      {:jason, "~> 1.1.0"},
      {:elixir_nsq, "~> 1.1.0"},
      {:conduit_nsq, "~> 0.1.4"},
      {:conduit, "~> 0.12.10"},
      {:absinthe, "~> 1.4.0"},
      {:absinthe_relay, "~> 1.4.0"},
      {:absinthe_conduit, path: "../absinthe_conduit"},
      {:plug, "~> 1.9.0"},
      {:plug_cowboy, "~> 2.1.2"},
      {:absinthe_plug, "~> 1.4.7"},
      {:ex_machina, "~> 2.3.0"},
      {:faker, "~> 0.13.0"}
    ]
  end

  defp aliases do
    [
      "ecto.seed": "run priv/repo/seeds.exs --no-start",
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seed"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end
end
