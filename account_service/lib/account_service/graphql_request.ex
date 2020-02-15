defmodule AccountService.GraphQLRequest do
  use Absinthe.Conduit.RequestHandler,
    broker: AccountService.Broker,
    schema: AccountService.Schema,
    response_topic: :graphql_response
end
