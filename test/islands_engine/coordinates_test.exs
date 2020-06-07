defmodule IslandsEngine.CoordinatesTest do
  use ExUnit.Case
  doctest IslandsEngine.Coordinates
  alias IslandsEngine.Coordinates

  describe "#new" do
    test "when coordinates are in range" do
      assert Coordinates.new(1, 10) == {:ok, %IslandsEngine.Coordinates{col: 10, row: 1}}
      assert Coordinates.new(10, 1) == {:ok, %IslandsEngine.Coordinates{col: 1, row: 10}}
    end

    test "when coordinates are out of range" do
      assert Coordinates.new(-1, 10) == {:error, :invalid_coordinates}
      assert Coordinates.new(11, 1) == {:error, :invalid_coordinates}
      assert Coordinates.new(5, 11) == {:error, :invalid_coordinates}
      assert Coordinates.new(9, 0) == {:error, :invalid_coordinates}
    end
  end
end
