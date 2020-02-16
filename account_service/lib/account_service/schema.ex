defmodule AccountService.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias Absinthe.{Resolution}

  alias AccountService
  alias AccountService.{TranslateErrors}

  def middleware(middleware, %{identifier: identifier} = field, object) do
    field_name = Atom.to_string(identifier)

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

  object :field_error do
    description("An user-readable error")

    field(:field, non_null(:string), description: "Error field")

    field(:message, non_null(:string), description: "Error description")
  end

  object :user do
    description("User of this wonderful platform")

    field(:id, non_null(:id), description: "User ID")
    field(:email, non_null(:string), description: "User email")
    field(:first_name, non_null(:string), description: "User first name")
    field(:last_name, non_null(:string), description: "User last name")
  end

  query do
    field(:users, non_null(list_of(non_null(:user))),
      resolve: fn _, _, _ ->
        {:ok, AccountService.get_users()}
      end
    )

    field :user, :user do
      description("Get user by email")
      arg(:email, non_null(:string), description: "User email")

      resolve(fn _, %{email: email}, _ ->
        {:ok, AccountService.get_by_email(email)}
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

        field :errors, non_null(list_of(non_null(:field_error))) do
          description("Mutation errors")

          middleware(TranslateErrors)
        end
      end

      resolve(fn _, args, _ ->
        case AccountService.register_user(args) do
          {:ok, user} -> %{user: user, errors: []}
          {:error, changeset} -> %{user: nil, errors: changeset}
        end
        |> (&{:ok, &1}).()
      end)
    end
  end
end
