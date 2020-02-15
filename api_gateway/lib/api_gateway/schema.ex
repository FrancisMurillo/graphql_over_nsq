defmodule ApiGateway.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias Absinthe.{Middleware, Resolution}
  alias Absinthe.Blueprint.Document.Field

  alias ApiGateway.{AccountClient}

  object :field_error do
    description("An user-readable error")

    field(:field, non_null(:string), description: "Error field")

    field(:message, non_null(:string), description: "Error description")
  end

  object :user do
    description("Users of this wonderful platform")

    field(:id, non_null(:id), description: "User ID")
    field(:email, non_null(:string), description: "User email")
    field(:first_name, non_null(:string), description: "User first name")
    field(:last_name, non_null(:string), description: "User last name")
  end

  def middleware(middleware, %{identifier: identifier} = field, object) do
    field_name =
      identifier
      |> Atom.to_string()
      |> Absinthe.Adapter.LanguageConventions.to_external_name(:field)

    new_middleware_spec = {{__MODULE__, :get_field_key}, {field_name, identifier}}

    Absinthe.Schema.replace_default(middleware, new_middleware_spec, field, object)
  end

  def get_field_key(%Resolution{source: source} = res, {key, fallback_key}) do
    new_value =
      case Map.fetch(source, key) do
        {:ok, value} ->
          value

        :error ->
          Map.get(source, fallback_key)
      end

    %{res | state: :resolved, value: new_value}
  end

  def to_field_query(%Field{name: name, selections: []}),
    do: name

  def to_field_query(%Field{name: name, selections: inner_fields}) do
    """
    #{name} {
    #{to_field_query(inner_fields)}
    }
    """
  end

  def to_field_query(fields) when is_list(fields) do
    fields
    |> Enum.map(&to_field_query/1)
    |> Enum.join("\n")
  end

  query do
    field :users, non_null(list_of(non_null(:user))) do
      resolve(fn _, _, res ->
        AccountClient.run("""
        query {
          users {
        #{to_field_query(res.definition.selections)}
          }
        }
        """)
        |> case do
          {:ok, %{"data" => %{"users" => users}}} ->
            {:ok, users}

          error ->
            error
        end
      end)
    end
  end

  mutation do
    payload field(:register_user) do
      description("Register user")

      input do
        field(:first_name, non_null(:string), description: "First name of the user")

        field(:last_name, non_null(:string), description: "Last name of the user")

        field(:email, non_null(:string), description: "User's email")
      end

      output do
        field(:user, :user, description: "Newly created user")

        field(:errors, non_null(list_of(non_null(:field_error))), description: "Mutation errors")
      end

      resolve(fn _, args, res ->
        AccountClient.run(
          """
          mutation($email: String!, $first_name: String!, $last_name: String!) {
            registerUser(
              input: {
                email: $email,
                firstName: $first_name,
                lastName: $last_name
              }
            ) {
          #{to_field_query(res.definition.selections)}
            }
          }
          """,
          args
        )
        |> IO.inspect(label: "RA")
        |> case do
          {:ok, %{"data" => %{"registerUser" => register_user}}} ->
            {:ok, register_user}

          error ->
            error
        end
      end)
    end
  end
end
