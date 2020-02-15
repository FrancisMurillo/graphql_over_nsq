defmodule TransactionService.Transaction do
  use Ecto.Schema

  alias Ecto.Changeset
  alias Faker
  alias UUID

  alias __MODULE__, as: Entity

  alias TransactionService.{TransactionItem}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field(:user_id, :binary_id)

    field(:code, :string)
    field(:total_price, :float)

    has_many(:items, TransactionItem)

    timestamps()
  end

  def create_changeset(%Entity{} = entity, user_id, attrs) do
    entity
    |> Changeset.cast(attrs, [])
    |> Changeset.cast_assoc(:items, with: &TransactionItem.create_changeset/2, required: true)
    |> validate_items(:items)
    |> Changeset.change(%{user_id: user_id, code: Faker.Code.isbn()})
  end

  defp validate_items(changeset, field) do
    Changeset.validate_change(changeset, field, fn _, items ->
      if(Enum.empty?(items), do: [{field, "#{field} cannot be empty"}], else: [])
    end)
  end
end
