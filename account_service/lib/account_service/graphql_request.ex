defmodule AccountService.GraphQLRequest do
  @moduledoc false

  use Conduit.Subscriber

  require Logger

  alias Absinthe
  alias Conduit.Message
  alias Ecto.Changeset

  alias AccountService.{Broker, Schema}

  def process(%Message{correlation_id: id, body: body} = message, _opts) when is_map(body)  do
    Logger.info("Received #{id} request")

    types = %{query: :string, variables: :map, context: :map}

    attrs = {%{}, types}
    |> Changeset.cast(body, Map.keys(types))
    |> Changeset.validate_required([:query])
    |> case do
         %Changeset{valid?: true} = changeset ->
           data = Changeset.apply_changes(changeset)

           query = Map.fetch!(data, :query)
           variables = Map.get(data, :variables, %{})
           context = Map.get(data, :context, %{})

           {:ok, response} = Absinthe.run(query, Schema, variables: variables, context: context)

           %Message{}
           |> Message.put_body(response)
           |> Message.put_correlation_id(id)
           |> Broker.publish(:graphql_response)
           |> case do
                {:ok, _} ->
                  Logger.info("Sent #{id} response")
                  :ok

                _ ->
                  Logger.error("Could not send #{id} response at account_graphql_response")
              end

         changeset ->
           Logger.error("GraphQL Error: #{inspect(changeset)}")

       end

    message
  end

  def process(message, _) do
    message
  end
end
