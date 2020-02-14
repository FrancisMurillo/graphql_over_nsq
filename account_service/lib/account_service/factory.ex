defmodule AccountService.Factory do
  use ExMachina.Ecto, repo: AccountService.Repo

  alias Faker

  alias AccountService.User

  def user_factory do
    %User{
      email: Faker.Internet.email(),
      first_name: Faker.Cat.name() |> String.upcase(),
      last_name: Faker.Cat.name() |> String.upcase()
    }
  end
end
