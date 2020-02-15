defmodule AccountService.User do
  use Ecto.Schema

  alias Ecto.Changeset

  alias __MODULE__, as: Entity

  @email_regex ~r/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)

    timestamps()
  end

  def register_changeset(%Entity{} = entity, attrs) do
    fields = [:email, :first_name, :last_name]

    entity
    |> Changeset.cast(attrs, fields)
    |> Changeset.validate_required(fields)
    |> validate_email(:email)
    |> validate_name(:first_name)
    |> validate_name(:last_name)
    |> Changeset.unique_constraint(:email)
  end

  def validate_email(changeset, field) do
    changeset
    |> Changeset.validate_length(field, max: 254)
    |> Changeset.validate_format(field, @email_regex)
  end

  def validate_name(changeset, field) do
    changeset
    |> Changeset.update_change(field, &String.trim/1)
    |> Changeset.validate_length(field, max: 150)
    |> Changeset.update_change(field, &String.upcase/1)
  end
end
