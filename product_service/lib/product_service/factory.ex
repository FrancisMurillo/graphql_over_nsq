defmodule ProductService.Factory do
  use ExMachina.Ecto, repo: ProductService.Repo

  alias Faker

  alias ProductService.Product

  def product_factory do
    %Product{
      code: Faker.Code.isbn(),
      name: Faker.Commerce.product_name(),
      price: Faker.Commerce.price()
    }
  end
end
