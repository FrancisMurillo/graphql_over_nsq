defmodule ApiGateway.TransactionGraphQLResponse do
  use Absinthe.Conduit.ResponseHandler,
    client: ApiGateway.TransactionClient
end
