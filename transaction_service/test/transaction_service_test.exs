defmodule TransactionServiceTest do
  use ExUnit.Case
  doctest TransactionService

  test "greets the world" do
    assert TransactionService.hello() == :world
  end
end
