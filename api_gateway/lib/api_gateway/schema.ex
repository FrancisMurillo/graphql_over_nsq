defmodule ApiGateway.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias Absinthe.{Resolution}
  alias Absinthe.Blueprint.Document.Field
  alias Absinthe.Middleware.PassParent

  alias ApiGateway.{AccountClient, ProductClient, TransactionClient, Authenticated}

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

    field :transactions, non_null(list_of(non_null(:user_transaction))) do
      description("User transactions")

      resolve(fn %{"id" => id}, _, res ->
        TransactionClient.run(
          """
          query($user_id: ID!) {
            user_transactions(user_id: $user_id) {
              id
              code
              items {
                id
                product_id
                price
                quantity
              }
            }
          }
          """,
          %{user_id: id},
          res.context
        )
        |> case do
          {:ok, %{"data" => %{"user_transactions" => user_transactions}}} ->
            {:ok, user_transactions}

          error ->
            error
        end
      end)
    end
  end

  object :product do
    description("Products of this wonderful platform")

    field(:id, non_null(:id), description: "Product ID")
    field(:code, non_null(:string), description: "Product email")
    field(:name, non_null(:string), description: "Product first name")
    field(:price, non_null(:float), description: "Product last name")
  end

  object :user_transaction do
    description("User transactions")

    field(:id, non_null(:id), description: "Transaction ID")

    field(:code, non_null(:string), description: "Transaction code")

    field(:items, non_null(list_of(non_null(:transaction_item))), description: "Transaction items")
  end

  object :transaction_item do
    description("Transaction item")

    field(:id, non_null(:id), description: "Transaction ID")

    field :product, non_null(:product) do
      description("Transaction product")

      resolve(fn %{"product_id" => product_id}, _, res ->
        ProductClient.run(
          """
          query($id: ID!) {
            product(id: $id) {
              id
              code
              name
              price
            }
          }
          """,
          %{id: product_id},
          res.context
        )
        |> case do
          {:ok, %{"data" => %{"product" => product}}} ->
            {:ok, product}

          error ->
            error
        end
      end)
    end

    field(:price, non_null(:float), description: "Transaction price")
    field(:quantity, non_null(:float), description: "Transaction quantity")
  end

  input_object :create_transaction_item do
    description("Create transaction item")

    field(:product_id, non_null(:id), description: "Item product ID")
    field(:quantity, non_null(:float), description: "Item product quantiy")
  end

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

  query do
    field :users, non_null(list_of(non_null(:user))) do
      resolve(fn _, _, res ->
        AccountClient.run("""
        query {
          users {
            id
            email
            first_name
            last_name
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

    field :products, non_null(list_of(non_null(:product))) do
      resolve(fn _, _, res ->
        ProductClient.run("""
        query {
          products {
            id
            code
            name
            price
          }
        }
        """)
        |> case do
          {:ok, %{"data" => %{"products" => products}}} ->
            {:ok, products}

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
            register_user(
              input: {
                email: $email
                first_name: $first_name
                last_name: $last_name
              }
            ) {
              errors {
                field
                message
              }
              user {
                id
                email
                first_name
                last_name
              }
            }
          }
          """,
          args
        )
        |> case do
          {:ok, %{"data" => %{"register_user" => register_user}}} ->
            {:ok, register_user}

          error ->
            error
        end
      end)
    end

    payload field(:create_transaction) do
      description("Create transaction")
      middleware(Authenticated)

      input do
        field(:items, non_null(list_of(non_null(:create_transaction_item))), description: "Items")
      end

      output do
        field(:transaction, :user_transaction, description: "Newly created transaction")

        field(:errors, non_null(list_of(non_null(:field_error))), description: "Mutation errors")
      end

      resolve(fn _, args, res ->
        TransactionClient.run(
          """
          mutation($items: [CreateTransactionItem!]!) {
            create_transaction(
              input: {
                items: $items
              }
            ) {
              errors {
                field
                message
              }
              transaction {
                id
                code
                items {
                  id
                  product_id
                  price
                  quantity
                }
              }
            }
          }
          """,
          args,
          res.context
        )
        |> case do
          {:ok, %{"data" => %{"create_transaction" => create_transaction}}} ->
            {:ok, create_transaction}

          error ->
            error
        end
      end)
    end
  end
end
