defmodule Absinthe.Conduit.ResponseHandler do
  defmacro __using__(opts) do
    client = Keyword.fetch!(opts, :client)

    quote do
      use Conduit.Subscriber

      alias Conduit.Message

      def process(%Message{correlation_id: id, body: body} = message, _opts) do
        :ok = unquote(client).receive_response(id, body)

        message
      end
    end
  end
end
