defmodule IslandsEngine.GuessesTest do
  use ExUnit.Case
  doctest IslandsEngine.Guesses
  alias IslandsEngine.Guesses

  describe "#new" do
    test "it should return Guesses struct" do
      assert {:ok, %IslandsEngine.Guesses{}} = Guesses.new()
    end

    test "it should return empty MapSets as hits and misses" do
      {:ok, %IslandsEngine.Guesses{hits: hits, misses: misses}} = Guesses.new()
      assert MapSet.new() == hits
      assert MapSet.new() == misses
    end
  end
end
