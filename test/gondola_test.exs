defmodule GondolaTest do
  use ExUnit.Case
  doctest Gondola

  test "greets the world" do
    assert Gondola.hello() == :world
  end
end
