defmodule ProductService do
  alias ProductService.{Repo, Product}

  def get_all() do
    Repo.all(Product)
  end

  def get_by_id(id) do
    Repo.get_by(Product, id: id)
  end
end
