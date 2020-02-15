defmodule ApiGateway.ProductGraphQLResponse do
  @moduledoc false

  use Conduit.Subscriber

  require Logger

  alias Conduit.Message

  alias ApiGateway.{ProductClient}

  def process(%Message{correlation_id: id, body: body} = message, _opts) do
    Logger.info("Received #{id} product response")

    :ok = ProductClient.receive_response(id, body)

    message
  end
end
