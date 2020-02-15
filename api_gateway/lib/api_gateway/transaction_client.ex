defmodule ApiGateway.TransactionClient do
  use Absinthe.Conduit.Client,
    broker: ApiGateway.Broker,
    request_topic: :transaction_graphql_request
end
