require Logger

Logger.info("> Seeding product database")

alias ProductService.{Factory, Repo, Product}

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

Enum.each([Product], fn schema ->
  Repo.delete_all(schema)
end)

Logger.info(">> Inserting 5 users")

Enum.each(1..10, fn _ ->
  Factory.insert(:product)
end)
