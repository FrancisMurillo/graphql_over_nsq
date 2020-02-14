defmodule ApiGateway.Schema do
  use Absinthe.Schema

  alias ApiGateway.{AccountClient}

  object :user do
    description("Users of this wonderful platform")

    field(:id, non_null(:id), description: "User ID")
    field(:email, non_null(:string), description: "User email")
    field(:first_name, non_null(:string), description: "User first name")
    field(:last_name, non_null(:string), description: "User last name")
  end

  query do
    field(:users, non_null(list_of(non_null(:user))),
      resolve: fn _, _, _ ->
        AccountClient.run("""
        query {
          users {
            id
            email
            firstName
            lastName
          }
        }
        """)
        |> case do
             {:ok, %{"data" => %{"users" => users}}} ->
               users
               |> Enum.map(&AtomicMap.convert/1)
               |> (&{:ok, &1}).()

             error ->
               error
           end
      end
    )
  end
end
