defmodule AccountService do
  alias AccountService.{Repo, User}

  def register_user(args) do
    %User{}
    |> User.register_changeset(args)
    |> Repo.insert()
  end
end
