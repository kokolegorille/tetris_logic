defmodule TetrisLogicTest do
  use ExUnit.Case
  doctest TetrisLogic

  test "greets the world" do
    assert TetrisLogic.hello() == :world
  end
end
