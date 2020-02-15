defmodule TransactionService.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add(:id, :binary_id, primary_key: true, autogenerate: true)
      add(:user_id, :binary_id, null: false)

      add(:code, :string, null: false)

      timestamps()
    end

    create unique_index(:transactions, [:code])
    create index(:transactions, [:user_id])
  end
end
