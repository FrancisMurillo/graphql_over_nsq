defmodule ProductService.Broker do
  use Conduit.Broker, otp_app: :product_service

  @channel "product_service"

  pipeline :serialize do
    plug(Conduit.Plug.Wrap)
    plug(Conduit.Plug.Encode, content_encoding: "json")
  end

  pipeline :deserialize do
    plug(Conduit.Plug.Decode, content_encoding: "json")
    plug(Conduit.Plug.Unwrap)
  end

  configure do
    queue("product_graphql_request")
    queue("product_graphql_response")
  end

  incoming ProductService do
    pipe_through([:deserialize])

    subscribe(
      :graphql_request,
      GraphQLRequest,
      topic: "product_graphql_request",
      channel: @channel
    )
  end

  outgoing do
    pipe_through([:serialize])

    publish(:graphql_response, topic: "product_graphql_response")
  end
end
