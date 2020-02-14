defmodule AccountService.Repo do
  use Ecto.Repo,
    otp_app: :account_service,
    adapter: Ecto.Adapters.Postgres
end
