defmodule ApiGateway.AccountClient do
  use Absinthe.Conduit.Client,
    broker: ApiGateway.Broker,
    request_topic: :account_graphql_request
end
