defmodule ProductService.Repo do
  use Ecto.Repo,
    otp_app: :product_service,
    adapter: Ecto.Adapters.Postgres
end
