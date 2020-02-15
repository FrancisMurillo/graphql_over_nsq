defmodule ApiGateway.AccountGraphQLResponse do
  use Absinthe.Conduit.ResponseHandler,
    client: ApiGateway.AccountClient
end
