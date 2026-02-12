defmodule ObanTestTest do
  use ExUnit.Case
  doctest ObanTest

  test "greets the world" do
    assert ObanTest.hello() == :world
  end
end
