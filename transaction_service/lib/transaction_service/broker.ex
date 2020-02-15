defmodule TransactionService.Broker do
  use Conduit.Broker, otp_app: :transaction_service

  @channel "transaction_service"

  pipeline :serialize do
    plug(Conduit.Plug.Wrap)
    plug(Conduit.Plug.Encode, content_encoding: "json")
  end

  pipeline :deserialize do
    plug(Conduit.Plug.Decode, content_encoding: "json")
    plug(Conduit.Plug.Unwrap)
  end

  configure do
    queue("transaction_graphql_response")

    queue("product_graphql_request")
  end

  incoming TransactionService do
    pipe_through([:deserialize])

    subscribe(
      :graphql_request,
      GraphQLRequest,
      topic: "transaction_graphql_request",
      channel: @channel
    )

    subscribe(
      :product_graphql_response,
      ProductGraphQLResponse,
      topic: "product_graphql_response",
      channel: @channel
    )
  end

  outgoing do
    pipe_through([:serialize])

    publish(:graphql_response, topic: "transaction_graphql_response")
    publish(:product_graphql_request, topic: "product_graphql_request")
  end
end
