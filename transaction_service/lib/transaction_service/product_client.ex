defmodule TransactionService.ProductClient do
  use Absinthe.Conduit.Client,
    broker: TransactionService.Broker,
    request_topic: :product_graphql_request

  alias Ecto.Changeset

  def get_by_id(id) do
    """
    query($id: ID!) {
      product(id: $id) {
        id
        code
        name
        price
      }
    }
    """
    |> run(%{id: id})
    |> case do
      {:ok, %{"data" => %{"product" => nil}}} ->
        nil

      {:ok, %{"data" => %{"product" => product}}} ->
        types = %{id: :string, code: :string, name: :string, price: :float}

        {%{}, types}
        |> Changeset.cast(product, Map.keys(types))
        |> Changeset.apply_changes()

      error ->
        error
    end
  end
end
