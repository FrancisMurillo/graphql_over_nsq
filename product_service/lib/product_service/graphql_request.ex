defmodule ProductService.GraphQLRequest do
  use Absinthe.Conduit.RequestHandler,
    broker: ProductService.Broker,
    schema: ProductService.Schema,
    response_topic: :graphql_response
end
