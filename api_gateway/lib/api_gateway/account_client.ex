defmodule ApiGateway.AccountClient do
  use Absinthe.Conduit.Client,
    broker: ApiGateway.Broker,
    request_topic: :account_graphql_request

  alias Ecto.Changeset

  def get_by_email(email) do
    """
    query($email: String!) {
      user(email: $email) {
        id
        email
        first_name
        last_name
      }
    }
    """
    |> run(%{email: email})
    |> case do
      {:ok, %{"data" => %{"user" => nil}}} ->
        nil

      {:ok, %{"data" => %{"user" => user}}} ->
        types = %{id: :string}

        {%{}, types}
        |> Changeset.cast(user, Map.keys(types))
        |> Changeset.apply_changes()

      error ->
        error
    end
  end
end
