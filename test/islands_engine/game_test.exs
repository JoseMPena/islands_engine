defmodule IslandsEngine.GameTest do
  use ExUnit.Case
  doctest IslandsEngine.Game
  alias IslandsEngine.{Coordinate, Game, Island, Rules}

  setup %{} do
    {:ok, game} = Game.start_link("Jose")
    [game: game]
  end

  describe "GenServer" do
    test "it should initialize the game with expected state", %{game: game} do
      assert %{
               player1: %{
                 board: %{},
                 guesses: %IslandsEngine.Guesses{hits: _, misses: _},
                 name: "Jose"
               },
               player2: %{
                 board: %{},
                 guesses: %IslandsEngine.Guesses{hits: _, misses: _},
                 name: nil
               },
               rules: %IslandsEngine.Rules{
                 player1: :islands_not_set,
                 player2: :islands_not_set,
                 state: :initialized
               }
             } = :sys.get_state(game)
    end
  end

  describe "#add_player/2" do
    test "it should add a second players name", %{game: game} do
      Game.add_player(game, "Marina")
      state = :sys.get_state(game)
      assert "Marina" = state.player2.name
    end
  end

  describe "#position_island/5" do
    setup %{} = context do
      state = Game.add_player(context.game, "Marina")
      [state: state]
    end

    test "it should allow player1 to position a square island", %{game: game} do
      {:ok, coordinate} = Coordinate.new(1, 1)
      {:ok, island} = Island.new(:square, coordinate)
      assert :ok = Game.position_island(game, :player1, :square, 1, 1)
      assert %{square: ^island} = :sys.get_state(game).player1.board
    end

    test "it should return an error when invalid coordinate", %{game: game} do
      assert {:error, :invalid_coordinate} = Game.position_island(game, :player1, :dot, 12, 1)
    end

    test "it should return an error when invalid island type", %{game: game} do
      assert {:error, :invalid_island_type} = Game.position_island(game, :player1, :wrong, 1, 1)
    end

    test "it should return an error when coordinate is off the board", %{game: game} do
      assert {:error, :invalid_coordinate} =
               Game.position_island(game, :player1, :l_shape, 10, 10)
    end

    test "it should return an error when the rules doesnt allow the action", %{game: game} do
      # setting the state ro :player1_turn so players can't position islands anymore
      :sys.replace_state(game, fn state ->
        %{state | rules: %Rules{state: :player1_turn}}
      end)

      assert :error = Game.position_island(game, :player1, :dot, 5, 5)
    end
  end

  describe "#set_island/2" do
    setup  %{game: game} do
      Game.add_player(game, "Marina")
      Game.position_island(game, :player1, :atoll, 1, 1)
      Game.position_island(game, :player1, :dot, 1, 4)
      Game.position_island(game, :player1, :l_shape, 1, 5)
      Game.position_island(game, :player1, :s_shape, 5, 1)
      Game.position_island(game, :player1, :square, 5, 5)
    end

    test "returns an error if player2 has pending islands to position", %{game: game} do
      assert {:error, :not_all_islands_positioned} = Game.set_island(game, :player2)
    end

    test "returns :ok and the board when islands are set for a user", %{game: game} do
      assert {:ok, board} = Game.set_island(game, :player1)
      assert Enum.all?([:atoll, :dot, :l_shape, :s_shape, :square], &(Map.has_key?(board, &1)))
      state = :sys.get_state(game)
      assert :islands_set = state.rules.player1
    end

    test "does not move to the next state if one player has not set islands", %{game: game} do
      {:ok, _} = Game.set_island(game, :player1)
      state = :sys.get_state(game)
      assert :players_set = state.rules.state
    end
  end

  describe "#guess_coordinate" do
    test "cannot guess when game state is :initialized", %{game: game} do
      assert :error = Game.guess_coordinate(game, :player1, 1, 1)
    end
  end

  describe "#guess_coordinate/2" do
    setup %{game: game} do
      Game.add_player(game, "Marina")
      Game.position_island(game, :player1, :dot, 1, 1)
      Game.position_island(game, :player2, :square, 1, 1)
      state_data = :sys.get_state(game)
      state_data = :sys.replace_state(game, fn _data ->
        %{state_data | rules: %Rules{state: :player1_turn}}
      end)

      [game: game, state: state_data]
    end

    test "responds with miss data structure when missing a guess", %{game: game} do
      assert {:miss, :none, :no_win} = Game.guess_coordinate(game, :player1, 5, 5)
    end

    test "player1 cannot guess again after missing a guess", %{game: game} do
      Game.guess_coordinate(game, :player1, 5, 5)
      assert :error = Game.guess_coordinate(game, :player1, 3, 1)
    end

    test "win the game when all islands are correctly guessed" do
      assert {:hit, :dot, :win} = Game.guess_coordinate(game, :player2, 1, 1)
    end
  end
end
