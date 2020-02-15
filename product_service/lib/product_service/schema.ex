defmodule ProductService.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias ProductService

  object :product do
    description("Products of this wonderful platform")

    field(:id, non_null(:id), description: "Product ID")
    field(:code, non_null(:string), description: "Product code")
    field(:name, non_null(:string), description: "Product name")
    field(:price, non_null(:float), description: "Product price")
  end

  query do
    field(:products, non_null(list_of(non_null(:product))),
      description: "All products avaiable",
      resolve: fn _, _, _ ->
        {:ok, ProductService.get_all()}
      end
    )

    field :product, :product do
      description("Get product by ID")
      arg :id, non_null(:id), description: "Product Id"

      resolve(fn _, %{id: id}, _ ->
        {:ok, ProductService.get_by_id(id)}
      end)
    end
  end
end
