defmodule TransactionService.Repo.Migrations.CreateTransactionItemsTable do
  use Ecto.Migration

  def change do
    create table(:transaction_items, primary_key: false) do
      add(:id, :binary_id, primary_key: true, autogenerate: true)
      add(:transaction_id, references(:transactions, column: :id, type: :binary_id, null: false))
      add(:product_id, :binary_id, null: false)

      add(:price, :float, null: false)
      add(:quantity, :float, null: false)

      timestamps()
    end

    create unique_index(:transaction_items, [:transaction_id, :product_id])
  end
end
