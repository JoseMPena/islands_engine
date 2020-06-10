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

  describe "#overlaps?/2" do
    test "it should check for overlapped islands" do
      {:ok, square_coordinate} = Coordinate.new(1, 1)
      {:ok, square} = Island.new(:square, square_coordinate)
      {:ok, dot_coordinate} = Coordinate.new(1, 2)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      {:ok, l_shape_coordinate} = Coordinate.new(5, 5)
      {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)

      assert Island.overlaps?(square, dot)
      assert not Island.overlaps?(square, l_shape)
      assert not Island.overlaps?(dot, l_shape)
    end
  end

  describe "#guess/2" do
    test "it should guess a miss" do
      {:ok, dot_coordinate} = Coordinate.new(4, 4)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      {:ok, coordinate} = Coordinate.new(2, 2)
      assert :miss = Island.guess(dot, coordinate)
    end

    test "it should guess a hit" do
      {:ok, dot_coordinate} = Coordinate.new(4, 4)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      {:ok, coordinate} = Coordinate.new(4, 4)
      hit_coordinates = MapSet.new([%IslandsEngine.Coordinate{col: 4, row: 4}])
      assert {:hit, %Island{hit_coordinates: ^hit_coordinates}} = Island.guess(dot, coordinate)
    end
  end

  describe "#forested?/1" do
    test "it tells when an island is forested" do
      {:ok, dot_coordinate} = Coordinate.new(4, 4)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      {:ok, coordinate} = Coordinate.new(4, 4)
      {:hit, dot} = Island.guess(dot, coordinate)

      assert Island.forested?(dot)
    end

    test "it tells when an island is not forested" do
      {:ok, dot_coordinate} = Coordinate.new(4, 4)
      {:ok, dot} = Island.new(:dot, dot_coordinate)

      assert not Island.forested?(dot)
    end
  end
end
