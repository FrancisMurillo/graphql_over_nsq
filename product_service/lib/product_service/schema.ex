defmodule ProductService.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias Absinthe.{Resolution}

  alias ProductService

  def middleware(middleware, %{identifier: identifier} = field, object) do
    field_name = Atom.to_string(identifier)

    new_middleware_spec = {{__MODULE__, :get_field_key}, {field_name, identifier}}

    Absinthe.Schema.replace_default(middleware, new_middleware_spec, field, object)
  end

  def get_field_key(%Resolution{source: source} = res, {key, fallback_key}) do
    new_value =
      case Map.fetch(source, key) do
        {:ok, value} ->
          value

        :error ->
          Map.get(source, fallback_key)
      end

    %{res | state: :resolved, value: new_value}
  end

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
      arg(:id, non_null(:id), description: "Product Id")

      resolve(fn _, %{id: id}, _ ->
        {:ok, ProductService.get_by_id(id)}
      end)
    end
  end
end
