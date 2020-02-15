defmodule ApiGateway.ProductClient do
  use Absinthe.Conduit.Client,
    broker: ApiGateway.Broker,
    request_topic: :product_graphql_request
end
