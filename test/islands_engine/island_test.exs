defmodule IslandsEngine.IslandTest do
  use ExUnit.Case
  doctest IslandsEngine.Island
  alias IslandsEngine.{Coordinate, Island}

  describe "#new" do
    test "it should build an 'l-shaped' island" do
      {:ok, coordinate} = Coordinate.new(4, 6)

      coordinates =
        MapSet.new([
          %IslandsEngine.Coordinate{col: 6, row: 4},
          %IslandsEngine.Coordinate{col: 6, row: 5},
          %IslandsEngine.Coordinate{col: 6, row: 6},
          %IslandsEngine.Coordinate{col: 7, row: 6}
        ])

      hit_coordinates = MapSet.new()

      assert {:ok,
              %IslandsEngine.Island{
                coordinates: ^coordinates,
                hit_coordinates: ^hit_coordinates
              }} = Island.new(:l_shape, coordinate)
    end

    test "it should return an error if the island type is invalid" do
      {:ok, coordinate} = Coordinate.new(4, 6)
      assert {:error, :invalid_island_type} = Island.new(:wrong, coordinate)
    end

    test "it should return an error if the first coordinate is invalid" do
      {:ok, coordinate} = Coordinate.new(10, 10)
      assert {:error, :invalid_coordinate} = Island.new(:l_shape, coordinate)
    end
  end
end
