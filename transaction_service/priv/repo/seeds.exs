require Logger

Logger.info("> Seeding transaction database")

alias TransactionService.{Repo, Transaction, TransactionItem}

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

Enum.each([Transaction, TransactionItem], fn schema ->
  Repo.delete_all(schema)
end)
