defmodule AccountServiceTest do
  use ExUnit.Case
  doctest AccountService

  test "greets the world" do
    assert AccountService.hello() == :world
  end
end
