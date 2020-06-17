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
end
