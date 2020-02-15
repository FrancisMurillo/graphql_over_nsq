defmodule ProductService.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias ProductService

  object :product do
    description("Products of this wonderful platform")

    field(:id, non_null(:id), description: "Product ID")
    field(:code, non_null(:string), description: "Product email")
    field(:name, non_null(:string), description: "Product first name")
    field(:price, non_null(:float), description: "Product last name")
  end

  query do
    field(:products, non_null(list_of(non_null(:product))),
      resolve: fn _, _, _ ->
        {:ok, ProductService.get_products()}
      end
    )
  end
end
