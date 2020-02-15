defmodule TransactionService do
  alias TransactionService.{Repo, Transaction}

  def create_transaction(user_id, args) do
    %Transaction{}
    |> Transaction.create_changeset(user_id, args)
    |> Repo.insert()
  end
end
