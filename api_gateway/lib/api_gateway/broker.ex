defmodule ApiGateway.Broker do
  use Conduit.Broker, otp_app: :api_gateway

  @channel "api_gateway"

  pipeline :serialize do
    plug(Conduit.Plug.Wrap)
    plug(Conduit.Plug.Encode, content_encoding: "json")
  end

  pipeline :deserialize do
    plug(Conduit.Plug.Decode, content_encoding: "json")
    plug(Conduit.Plug.Unwrap)
  end

  configure do
    queue("account_graphql_request")
    queue("product_graphql_request")
    queue("transaction_graphql_request")
  end

  incoming ApiGateway do
    pipe_through([:deserialize])

    subscribe(
      :account_graphql_response,
      AccountGraphQLResponse,
      topic: "account_graphql_response",
      channel: @channel
    )

    subscribe(
      :product_graphql_response,
      ProductGraphQLResponse,
      topic: "product_graphql_response",
      channel: @channel
    )

    subscribe(
      :transaction_graphql_response,
      TransactionGraphQLResponse,
      topic: "transaction_graphql_response",
      channel: @channel
    )
  end

  outgoing do
    pipe_through([:serialize])

    publish(:account_graphql_request, topic: "account_graphql_request")
    publish(:product_graphql_request, topic: "product_graphql_request")
    publish(:transaction_graphql_request, topic: "transaction_graphql_request")
  end
end
