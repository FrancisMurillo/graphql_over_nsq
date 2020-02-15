defmodule TransactionService.ProductGraphQLResponse do
  use Absinthe.Conduit.ResponseHandler,
    client: TransactionService.ProductClient
end
