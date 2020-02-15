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

      resolve(fn %{"_id" => id}, _, res ->
        TransactionClient.run(
          """
          query($user_id: ID!) {
            userTransactions(userId: $user_id) {
              id
              code
              items {
                id
                price
                quantity
                _product_id: productId
              }
            }
          }
          """,
          %{user_id: id},
          res.context
        )
        |> case do
          {:ok, %{"data" => %{"userTransactions" => user_transactions}}} ->
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

      resolve(fn %{"_product_id" => product_id}, _, res ->
        ProductClient.run(
          """
          query($id: ID!) {
            product(id: $id) {
          #{to_field_query(res.definition.selections, [])}
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

  def to_field_query(%Field{name: name, selections: []}, excluded_fields),
    do: name

  def to_field_query(%Field{name: name, selections: inner_fields}, excluded_fields) do
    if name in excluded_fields do
      ""
    else
      """
      #{name} {
      #{to_field_query(inner_fields, excluded_fields)}
      }
      """
    end
  end

  def to_field_query(fields, excluded_fields) when is_list(fields) do
    fields
    |> Enum.map(fn field -> to_field_query(field, excluded_fields) end)
    |> Enum.join("\n")
  end

  query do
    field :users, non_null(list_of(non_null(:user))) do
      resolve(fn _, _, res ->
        AccountClient.run("""
        query {
          users {
          _id: id
        #{to_field_query(res.definition.selections, ["transactions"])}
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
        #{to_field_query(res.definition.selections, [])}
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
            registerUser(
              input: {
                email: $email
                firstName: $first_name
                lastName: $last_name
              }
            ) {
          #{to_field_query(res.definition.selections, [])}
            }
          }
          """,
          args
        )
        |> case do
          {:ok, %{"data" => %{"registerUser" => register_user}}} ->
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
            createTransaction(
              input: {
                items: $items
              }
            ) {
          #{to_field_query(res.definition.selections, [])}
            }
          }
          """,
          args,
          res.context
        )
        |> case do
          {:ok, %{"data" => %{"createTransaction" => create_transaction}}} ->
            {:ok, create_transaction}

          error ->
            error
        end
      end)
    end
  end
end
