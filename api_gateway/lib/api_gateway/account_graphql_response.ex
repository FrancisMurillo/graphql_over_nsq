defmodule ApiGateway.AccountGraphQLResponse do
  @moduledoc false

  use Conduit.Subscriber

  require Logger

  alias Conduit.Message

  alias ApiGateway.{AccountClient}

  def process(%Message{correlation_id: id, body: body} = message, _opts) do
    Logger.info("Received #{id} account response")

    :ok = AccountClient.receive_response(id, body)

    message
  end
end
