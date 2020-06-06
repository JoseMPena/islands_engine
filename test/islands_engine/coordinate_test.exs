defmodule IslandsEngine.CoordinateTest do
  use ExUnit.Case
  doctest IslandsEngine.Coordinate
  alias IslandsEngine.Coordinate

  describe "#new" do
    test "when coordinates are in range" do
      assert Coordinate.new(1, 10) == {:ok, %IslandsEngine.Coordinate{col: 10, row: 1}}
      assert Coordinate.new(10, 1) == {:ok, %IslandsEngine.Coordinate{col: 1, row: 10}}
    end

    test "when coordinates are out of range" do
      assert Coordinate.new(-1, 10) == {:error, :invalid_coordinate}
      assert Coordinate.new(11, 1) == {:error, :invalid_coordinate}
      assert Coordinate.new(5, 11) == {:error, :invalid_coordinate}
      assert Coordinate.new(9, 0) == {:error, :invalid_coordinate}
    end
  end
end
