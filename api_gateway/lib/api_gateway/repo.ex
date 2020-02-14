defmodule ApiGateway.Repo do
  use Ecto.Repo,
    otp_app: :api_gateway,
    adapter: Ecto.Adapters.Postgres
end
