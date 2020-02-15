defmodule TransactionService.TransactionItem do
  use Ecto.Schema

  alias Ecto.Changeset

  alias __MODULE__, as: Entity

  alias TransactionService.{ProductClient}
  alias TransactionProduct.{Transaction}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transaction_items" do
    field :product_id, :binary_id

    field :price, :float
    field :quantity, :float

    belongs_to(:transaction, Transaction, type: :binary_id, foreign_key: :transaction_id)

    timestamps()
  end

  def create_changeset(%Entity{} = entity, attrs) do
    fields = [:product_id, :quantity]

    entity
    |> Changeset.cast(attrs, fields)
    |> Changeset.validate_required(fields)
    |> validate_product(:product_id)
    |> validate_quantity(:quantity)
    |> Changeset.unique_constraint(:product_id, name: :transaction_items_transaction_id_product_id_index)
  end

  def validate_product(changeset, field) do
    if changeset.valid? do
      product = changeset
      |> Changeset.fetch_change!(:product_id)
      |> ProductClient.get_by_id()

      if product do
        price = Map.get(product, :price, 0)

        Changeset.change(changeset, %{price: price})
      else
        Changeset.add_error(changeset, field, "does not exist")
      end
    else
      changeset
    end
  end

  def validate_quantity(changeset, field) do
    changeset
    |> Changeset.validate_number(field, greater_than: 0)
  end
end
