defmodule ApiGateway.AccountClient do
  use Supervisor

  require Logger

  alias Conduit.Message
  alias Registry
  alias UUID

  alias ApiGateway.Broker

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
      name: ApiGateway.AccountClientSupervisor
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
      |> Broker.publish(:account_graphql_request)
      |> case do
        {:ok, _} ->
          Logger.info("Sent #{request_id} account request")

          receive do
            response ->
              Logger.info("Received #{request_id} account request")

              {:ok, response}
          after
            response_timeout() ->
              Logger.info("Could not wait for #{request_id} account request")

              {:error, :response_timeout}
          end

        _ ->
          Logger.info("Could not send #{request_id} account request")
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

  defp response_timeout() do
    :timer.seconds(15)
  end
end
