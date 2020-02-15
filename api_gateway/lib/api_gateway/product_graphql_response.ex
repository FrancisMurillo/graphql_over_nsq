defmodule ApiGateway.ProductGraphQLResponse do
  use Absinthe.Conduit.ResponseHandler,
    client: ApiGateway.ProductClient
end
