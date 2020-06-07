defmodule IslandsEngine.GuessesTest do
  use ExUnit.Case
  doctest IslandsEngine.Guesses
  alias IslandsEngine.{Guesses, Coordinate}

  describe "#new/0" do
    test "it should return Guesses struct" do
      assert {:ok, %IslandsEngine.Guesses{}} = Guesses.new()
    end

    test "it should return empty MapSets as hits and misses" do
      {:ok, %IslandsEngine.Guesses{hits: hits, misses: misses}} = Guesses.new()
      assert MapSet.new() == hits
      assert MapSet.new() == misses
    end
  end

  describe "#add/3" do
    test "it should add hit coordinates" do
      {:ok, guesses} = Guesses.new()
      {:ok, coordinate} = Coordinate.new(8, 3)
      hits = MapSet.new([%IslandsEngine.Coordinate{col: 3, row: 8}])

      misses = MapSet.new()

      assert %IslandsEngine.Guesses{
               hits: ^hits,
               misses: ^misses
             } = Guesses.add(guesses, :hit, coordinate)
    end

    test "it should add a miss coordinate" do
      {:ok, guesses} = Guesses.new()
      {:ok, coordinate} = Coordinate.new(1, 2)
      misses = MapSet.new([%IslandsEngine.Coordinate{col: 2, row: 1}])
      hits = MapSet.new()

      assert %IslandsEngine.Guesses{
               hits: ^hits,
               misses: ^misses
             } = Guesses.add(guesses, :miss, coordinate)
    end
  end
end
