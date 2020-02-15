defmodule AccountService do
  alias AccountService.{Repo, User}

  def get_users() do
    Repo.all(User)
  end

  def get_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def register_user(args) do
    %User{}
    |> User.register_changeset(args)
    |> Repo.insert()
  end
end
