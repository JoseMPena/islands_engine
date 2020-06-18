defmodule IslandsEngine.GameSupervisorTest do
  use ExUnit.Case
  doctest IslandsEngine.GameSupervisor
  alias IslandsEngine.{Game, GameSupervisor}

  test "starts a game as a process" do
    GameSupervisor.start_game("name")

    assert %{active: 1, specs: 1, supervisors: 0, workers: 1} =
             Supervisor.count_children(GameSupervisor)
  end

  test "stops the game process" do
    {:ok, game} = GameSupervisor.start_game("name")
    assert :ok = GameSupervisor.stop_game("name")
    assert !Process.alive?(game)
  end

  describe "saving state in-memory" do
    setup %{} do
      {:ok, game} = GameSupervisor.start_game("Jose")
      on_exit(fn  -> Process.exit(game, :kaboom) end)
      [game: game]
    end

    test "it starts off by creating a :game_state table with initial state" do
      [{"Jose", value}] = :ets.lookup(:game_state, "Jose")
      assert "Jose" = value.player1.name
      assert nil = value.player2.name
    end

    test "it overwrites the old in-memory state when game state changes", %{game: game} do
      :ok = Game.add_player(game, "Marina")
      [{"Jose", value}] = :ets.lookup(:game_state, "Jose")
      assert "Jose" = value.player1.name
      assert "Marina" = value.player2.name
    end
  end
end
