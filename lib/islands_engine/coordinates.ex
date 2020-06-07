defmodule IslandsEngine.Coordinates do
  alias __MODULE__
  @enforce_keys [:row, :col]
  @board_range 1..10
  defstruct [:row, :col]

  def new(row, col) when row in @board_range and col in @board_range do
    {:ok, %Coordinates{row: row, col: col}}
  end

  def new(_row, _col), do: {:error, :invalid_coordinates}
end