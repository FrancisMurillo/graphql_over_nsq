defmodule TransactionService.Repo do
  use Ecto.Repo,
    otp_app: :transaction_service,
    adapter: Ecto.Adapters.Postgres,
    migration_source: "transaction_migrations"
end
