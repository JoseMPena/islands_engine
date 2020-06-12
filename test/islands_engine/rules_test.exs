defmodule IslandsEngine.RulesTest do
  use ExUnit.Case
  doctest IslandsEngine.Rules
  alias IslandsEngine.Rules

  describe "#new" do
    test "it should respond with the initial state" do
      assert %IslandsEngine.Rules{state: :initialized} = Rules.new()
    end
  end

  setup %{} do
    [rules: Rules.new()]
  end

  describe "check/2 when state is just initialized" do
    test "it should update its state to :players_set", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, :add_player)
      assert :players_set = rules.state
    end

    test "it should return an error if the actoin is unexpected", %{rules: rules} do
      assert :error = Rules.check(rules, :checkout)
      assert :initialized = rules.state
    end
  end

  describe "check/2 when state is :players_set" do
    setup %{} = context do
      [rules: %{context.rules | state: :players_set}]
    end

    test "it should allow further moves when player has not set islands", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
      assert :players_set = rules.state
    end

    test "a user can set her islands just once", %{rules: rules} do
      rules = %{rules | player1: :islands_set}
      assert :error = Rules.check(rules, {:position_islands, :player1})
      assert :players_set = rules.state
    end

    test "it should update players status when setting islands", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      assert :islands_set = rules.player1
    end

    test "it should not transition state until both players are set", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      assert :players_set = rules.state
    end

    test "it should transition to :player1_turn when both players are island_set", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      assert :player1_turn = rules.state
    end

    test "it should not allow setting islands after both players are island_set", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      assert :error = Rules.check(rules, {:set_islands, :player1})
      assert :error = Rules.check(rules, {:set_islands, :player2})
    end
  end

  describe "check/2 when state is :player1_turn" do
    setup %{} = context do
      [rules: %{context.rules | state: :player1_turn}]
    end

    test "it should transition to :player2_turn after player1 has guessed", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
      assert :player2_turn = rules.state
    end

    test "it should return error when player guesses out of her turn", %{rules: rules} do
      assert :error = Rules.check(rules, {:guess_coordinate, :player2})
    end

    test "it should transition to :game_over for a :win event", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:win_check, :win})
      assert :game_over = rules.state
    end

    test "it should not transition state when guess is :no_win", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
      assert :player1_turn = rules.state
    end
  end

  describe "check/2 when state is :player2_turn" do
    setup %{} = context do
      [rules: %{context.rules | state: :player2_turn}]
    end

    test "it should transition to :player1_turn after player2 has guessed", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
      assert :player1_turn = rules.state
    end

    test "it should return error when player guesses out of her turn", %{rules: rules} do
      assert :error = Rules.check(rules, {:guess_coordinate, :player1})
    end

    test "it should transition to :game_over for a :win event", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:win_check, :win})
      assert :game_over = rules.state
    end

    test "it should not transition state when guess is :no_win", %{rules: rules} do
      {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
      assert :player2_turn = rules.state
    end
  end
end
