defmodule ProductService do
  alias ProductService.{Repo, Product}

  def get_products() do
    Repo.all(Product)
  end
end
