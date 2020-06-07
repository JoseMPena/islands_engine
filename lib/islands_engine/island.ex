defmodule IslandsEngine.Island do
  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} -> {:cont, MapSet.put(coordinates, coordinate)}
      {:error, error} -> {:halt, {:error, error}}
    end
  end

  defp offsets(type, offset \\ {0, 0})

  defp offsets(:square, {row, col}) do
    [{row, col}, {row, col + 1}, {row + 1, col}, {row + 1, col + 1}]
  end

  defp offsets(:atoll, {row, col}) do
    [{row, col}, {row, col + 1}, {row + 1, col + 1}, {row + 2, col}, {row + 2, col + 1}]
  end

  defp offsets(:dot, offset), do: [offset]

  defp offsets(:l_shape, {row, col}) do
    [{row, col}, {row + 1, col}, {row + 2, col}, {row + 2, col + 1}]
  end

  defp offsets(:s_shape, {row, col}) do
    [{row, col + 1}, {row, col + 2}, {row + 1, col}, {row + 1, col + 1}]
  end

  defp offsets(_, _), do: {:error, :invalid_island_type}
end
