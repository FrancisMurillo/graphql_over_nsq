defmodule TransactionService.GraphQLRequest do
  use Absinthe.Conduit.RequestHandler,
    broker: TransactionService.Broker,
    schema: TransactionService.Schema,
    response_topic: :graphql_response
end
