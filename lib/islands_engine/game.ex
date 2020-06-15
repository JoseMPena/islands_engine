defmodule IslandsEngine.Game do
  use GenServer

  alias IslandsEngine.{Board, Coordinate, Guesses, Island, Rules}

  @players [:player1, :player2]

  # API
  @spec start_link(binary) :: any
  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  @spec add_player(atom | pid | {atom, any} | {:via, atom, any}, binary) :: any
  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  @spec position_island(
          atom | pid | {atom, any} | {:via, atom, any},
          :player1 | :player2,
          any,
          any,
          any
        ) :: any
  def position_island(game, player, key, row, col) when player in @players do
    GenServer.call(game, {:position_island, player, key, row, col})
  end

  @spec set_island(atom | pid | {atom, any} | {:via, atom, any}, :player1 | :player2) :: any
  def set_island(game, player) when player in @players do
    GenServer.call(game, {:set_islands, player})
  end

  @spec guess_coordinate(
          atom | pid | {atom, any} | {:via, atom, any},
          :player1 | :player2,
          any,
          any
        ) :: any
  def guess_coordinate(game, player, row, col) when player in @players do
    GenServer.call(game, {:guess_coordinate, player, row, col})
  end

  @spec via_tuple(any) :: {:via, Registry, {Registry.Game, any}}
  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}

  # Server

  @spec init(any) ::
          {:ok,
           %{
             player1: %{board: map, guesses: map, name: any},
             player2: %{board: map, guesses: map, name: any},
             rules: IslandsEngine.Rules.t()
           }}
  def init(name) do
    player1 = init_player(name)
    player2 = init_player(nil)
    {:ok, %{player1: player1, player2: player2, rules: %Rules{}}}
  end

  def handle_info(:first, state) do
    IO.puts("this message has been handled by handle_info/2")
    {:noreply, state}
  end

  def handle_call({:add_player, name}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, :add_player) do
      state
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:position_island, player, key, row, col}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:position_islands, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {:ok, island} <- Island.new(key, coordinate),
         %{} = board <- Board.position_island(board, key, island) do
      state
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  def handle_call({:set_islands, player}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:set_islands, player}),
         true <- Board.all_islands_positioned?(board) do
      state
      |> update_rules(rules)
      |> reply_success({:ok, board})
    else
      :error -> {:reply, :error, state}
      false -> {:reply, {:error, :not_all_islands_positioned}, state}
    end
  end

  def handle_call({:guess_coordinate, player_key, row, col}, _from, state_data) do
    opponent_key = opponent(player_key)
    opponent_board = player_board(state_data, opponent_key)

    with {:ok, rules} <- Rules.check(state_data.rules, {:guess_coordinate, player_key}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {hit_or_miss, forested_island, win_status, opponent_board} <-
           Board.guess(opponent_board, coordinate),
         {:ok, rules} <- Rules.check(rules, {:win_check, win_status}) do
      state_data
      |> update_board(opponent_key, opponent_board)
      |> update_guesses(player_key, hit_or_miss, coordinate)
      |> update_rules(rules)
      |> reply_success({hit_or_miss, forested_island, win_status})
    else
      :error -> {:reply, :error, state_data}
      {:error, :invalid_coordinate} -> {:reply, {:error, :invalid_coordinate}, state_data}
    end
  end

  # Support funcs

  defp init_player(name) do
    {:ok, board} = Board.new()
    {:ok, guesses} = Guesses.new()
    %{name: name, board: board, guesses: guesses}
  end

  defp update_player2_name(state, name) when is_binary(name) do
    put_in(state.player2.name, name)
  end

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp reply_success(state, reply), do: {:reply, reply, state}

  defp player_board(state, player), do: Map.get(state, player).board

  defp update_board(state, player, board) do
    Map.update!(state, player, fn player ->
      %{player | board: board}
    end)
  end

  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1

  defp update_guesses(state_data, player_key, hit_or_miss, coordinate) do
    update_in(state_data[player_key].guesses, fn guesses ->
      Guesses.add(guesses, hit_or_miss, coordinate)
    end)
  end
end
