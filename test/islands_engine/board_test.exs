defmodule IslandsEngine.BoardTest do
  use ExUnit.Case
  doctest IslandsEngine.Board
  alias IslandsEngine.Board

  describe "#new" do
    test "it should initialize with an empty map" do
      assert {:ok, %{}} = Board.new()
    end
  end
end
