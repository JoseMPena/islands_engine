defmodule IslandsEngine.BoardTest do
  use ExUnit.Case
  doctest IslandsEngine.Board
  alias IslandsEngine.{Board, Coordinate, Island}

  setup_all do
    {:ok, board} = Board.new()
    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)
    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    [
      square: square,
      board: Board.position_island(board, :square, square),
      dot: dot
    ]
  end

  describe "#new" do
    test "it should initialize with an empty map" do
      assert {:ok, %{}} = Board.new()
    end
  end

  describe "#position_island/3" do
    test "it positions the island inside the board if no overlaps", %{
      board: board,
      square: square
    } do
      assert %{square: ^square} = Board.position_island(board, :square, square)
    end

    test "it can position multiple islands", %{board: board, square: square} do
      {:ok, dot_coordinate} = Coordinate.new(3, 3)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      assert %{square: ^square, dot: ^dot} = Board.position_island(board, :dot, dot)
    end

    test "it returns an error if positioning island overlaps", %{board: board, dot: dot} do
      assert {:error, :overlapping_island} = Board.position_island(board, :dot, dot)
    end
  end

  describe "#all_islands_positioned/1" do
    test "it return false when not all islands are positioned" do
    end
  end

  describe "#guess/2" do
    test "it should return the expected data structure for missed guess", %{board: board} do
      {:ok, guess_coordinate} = Coordinate.new(10, 10)
      assert {:miss, :none, :no_win, board} = Board.guess(board, guess_coordinate)
    end

    test "it should return the expected data structure for hit guess", %{board: board} do
      {:ok, guess_coordinate} = Coordinate.new(1, 1)
      assert {:hit, :none, :no_win, board} = Board.guess(board, guess_coordinate)
    end

    test "it should return the expected data structure when all islands are guessed", %{
      board: board,
      square: square
    } do
      square = %{square | hit_coordinates: square.coordinates}
      board = Board.position_island(board, :square, square)
      {:ok, win_coordinate} = Coordinate.new(1, 1)
      assert {:hit, :square, :win, board} = Board.guess(board, win_coordinate)
    end
  end
end
