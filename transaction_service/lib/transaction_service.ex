defmodule TransactionService do
  import Ecto.Query

  alias TransactionService.{Repo, Transaction}

  def get_all_user_transactions(user_id) do
    from(t in Transaction, where: t.user_id == ^user_id, preload: [:items])
    |> Repo.all()
  end

  def create_transaction(user_id, args) do
    %Transaction{}
    |> Transaction.create_changeset(user_id, args)
    |> Repo.insert()
  end
end
