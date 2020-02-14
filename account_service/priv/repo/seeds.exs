require Logger

Logger.info("> Seeding account database")

alias AccountService.{Factory, Repo, User}

[
  :postgrex,
  :ecto,
  :ecto_sql,
  :faker,
  :tzdata
]
|> Enum.each(&Application.ensure_all_started/1)

Repo.start_link(pool_size: 2)

Logger.info(">> Clearing database")

Enum.each([User], fn schema ->
  Repo.delete_all(schema)
end)

Logger.info(">> Inserting 5 users")

Enum.each(1..5, fn _ ->
  Factory.insert(:user)
end)
