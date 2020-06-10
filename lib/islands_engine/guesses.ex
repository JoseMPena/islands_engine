defmodule IslandsEngine.Guesses do
  alias IslandsEngine.{Coordinate, Guesses}

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @spec new :: {:ok, %IslandsEngine.Guesses{}}
  def new() do
    {:ok, %Guesses{hits: MapSet.new(), misses: MapSet.new()}}
  end

  @spec add(%IslandsEngine.Guesses{}, :hit | :miss, IslandsEngine.Coordinate.t()) :: map
  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate) do
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  end

  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate) do
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
  end
end
