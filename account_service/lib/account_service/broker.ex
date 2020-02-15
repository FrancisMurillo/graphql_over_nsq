defmodule AccountService.Broker do
  use Conduit.Broker, otp_app: :account_service

  @channel "account_service"

  pipeline :serialize do
    plug(Conduit.Plug.Wrap)
    plug(Conduit.Plug.Encode, content_encoding: "json")
  end

  pipeline :deserialize do
    plug(Conduit.Plug.Decode, content_encoding: "json")
    plug(Conduit.Plug.Unwrap)
  end

  configure do
    queue("account_graphql_response")
  end

  incoming AccountService do
    pipe_through([:deserialize])

    subscribe(
      :graphql_request,
      GraphQLRequest,
      topic: "account_graphql_request",
      channel: @channel
    )
  end

  outgoing do
    pipe_through([:serialize])

    publish(:graphql_response, topic: "account_graphql_response")
  end
end
