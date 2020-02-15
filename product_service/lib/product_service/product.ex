defmodule ProductService.Product do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field(:code, :string)
    field(:name, :string)
    field(:price, :float)

    timestamps()
  end
end
