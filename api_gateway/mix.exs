defmodule ApiGateway.MixProject do
  use Mix.Project

  def project do
    [
      app: :api_gateway,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ApiGateway.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4.13"},
      {:phoenix_pubsub, "~> 1.1.0"},
      {:plug_cowboy, "~> 2.1.2"},
      {:uuid, "~> 1.1.8", app: false, runtime: false, override: true},
      {:jason, "~> 1.1.0"},
      {:elixir_uuid, "~> 1.2.0"},
      {:elixir_nsq, "~> 1.1.0"},
      {:conduit_nsq, "~> 0.1.4"},
      {:conduit, "~> 0.12.10"},
      {:absinthe, "~> 1.4.0"},
      {:absinthe_relay, "~> 1.4.0"},
      {:absinthe_conduit, path: "../absinthe_conduit"},
      {:absinthe_plug, "~> 1.4.7"}
    ]
  end
end
