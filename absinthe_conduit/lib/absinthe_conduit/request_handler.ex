defmodule Absinthe.Conduit.RequestHandler do
  defmacro __using__(opts) do
    broker = Keyword.fetch!(opts, :broker)
    schema = Keyword.fetch!(opts, :schema)
    response_topic = Keyword.fetch!(opts, :response_topic)

    quote do
      use Conduit.Subscriber

      require Logger

      alias Absinthe
      alias Conduit.Message
      alias Ecto.Changeset

      def process(%Message{correlation_id: id, body: body} = message, _opts) when is_map(body) do
        Logger.info("Received #{id} message")
        types = %{query: :string, variables: :map, context: :map}

        {%{}, types}
        |> Changeset.cast(body, Map.keys(types))
        |> Changeset.validate_required([:query])
        |> case do
          %Changeset{valid?: true} = changeset ->
            data = Changeset.apply_changes(changeset)

            query = Map.fetch!(data, :query)
            variables = Map.get(data, :variables, %{})
            context = Map.get(data, :context, %{})

            Absinthe.Logger.log_run(:info, {
              query,
              schema(),
              nil,
              []
            })

            {:ok, response} =
              Absinthe.run(query, schema(), variables: variables, context: context)

            %Message{}
            |> Message.put_body(response)
            |> Message.put_correlation_id(id)
            |> broker().publish(response_topic())
            |> case do
              {:ok, _} ->
                   Logger.info("Responsed to #{id} message")

              _ ->
                Logger.info("Could not publish #{id}/#{response_topic()} message")
            end

          changeset ->
               Logger.info("Invalid message for #{response_topic()}")

        end

        message
      end

      def process(message, _) do
        message
      end

      def broker() do
        unquote(broker)
      end

      def schema() do
        unquote(schema)
      end

      def response_topic() do
        unquote(response_topic)
      end
    end
  end
end
