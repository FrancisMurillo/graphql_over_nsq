defmodule AbsintheConduit.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_conduit,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:conduit, "~> 0.12.10"},
      {:absinthe, "~> 1.4.0"},
      {:jason, "~> 1.1.0"},
      {:elixir_uuid, "~> 1.2.0"}
    ]
  end
end
