defmodule ProductService.Repo.Migrations.CreateProductsTable do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add(:id, :binary_id, primary_key: true, autogenerate: true)

      add(:code, :string, null: false)
      add(:name, :string, null: false)
      add(:price, :float, null: false)

      timestamps()
    end

    create unique_index(:products, [:code])
  end
end
