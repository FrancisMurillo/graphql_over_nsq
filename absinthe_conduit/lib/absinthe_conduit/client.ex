defmodule Absinthe.Conduit.Client do
  defmacro __using__(opts) do
    broker = Keyword.fetch!(opts, :broker)
    request_topic = Keyword.fetch!(opts, :request_topic)

    quote do
      use Supervisor

      require Logger

      alias Conduit.Message
      alias Registry
      alias UUID

      @registry Module.concat(__MODULE__, Registry)

      def start_link(opts) do
        Supervisor.start_link(__MODULE__, opts)
      end

      @impl true
      def init(_opts) do
        children = [
          {Registry, keys: :unique, name: @registry}
        ]

        Supervisor.init(children,
          strategy: :one_for_one,
          restart: :transient,
          name: Module.concat(__MODULE__, Supervisor)
        )
      end

      def run(query, variables \\ %{}, context \\ %{}) do
        request_id = UUID.uuid4()

        {:ok, _} = Registry.register(@registry, request_id, :graphql)

        result =
          %Message{}
          |> Message.put_correlation_id(request_id)
          |> Message.put_body(%{
            query: query,
            variables: variables,
            context: context
          })
          |> broker().publish(request_topic())
          |> case do
            {:ok, _} ->
              receive do
                response ->
                  {:ok, response}
              after
                response_timeout() ->
                  {:error, :response_timeout}
              end

            error ->
              error
          end

        :ok = Registry.unregister(@registry, request_id)

        result
      end

      def receive_response(id, response) do
        case Registry.lookup(@registry, id) do
          [{pid, :graphql}] ->
            send(pid, response)

          _ ->
            nil
        end

        :ok
      end

      def broker() do
        unquote(broker)
      end

      def request_topic() do
        unquote(request_topic)
      end

      defp response_timeout() do
        :timer.seconds(30)
      end
    end
  end
end
