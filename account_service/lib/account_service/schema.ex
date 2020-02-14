defmodule AccountService.Schema do
  use Absinthe.Schema

  alias AccountService.{Repo, User}

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
        {:ok, Repo.all(User)}
      end
    )
  end
end
