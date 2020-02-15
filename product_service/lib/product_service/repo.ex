defmodule ProductService.Repo do
  use Ecto.Repo,
    otp_app: :product_service,
    adapter: Ecto.Adapters.Postgres,
    migration_source: "product_migrations"
end
