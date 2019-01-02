defmodule Islands.Game do

"""
alias Islands.{Game, Rules}
via = Game.via_tuple("Col")

{:ok, g} = Game.start_link("Col", name: via)

Game.add_player(g, "Bronzie")

Game.position_island(g, :player1, :atoll,1,1)
Game.position_island(g, :player1, :dot,1,4)
Game.position_island(g, :player1, :l_shape,1,5)
Game.position_island(g, :player1, :s_shape,5,1)
Game.position_island(g, :player1, :square,5,5)
Game.position_island(g, :player2, :atoll,1,1)
Game.position_island(g, :player2, :dot,1,4)
Game.position_island(g, :player2, :l_shape,1,5)
Game.position_island(g, :player2, :s_shape,5,1)
Game.position_island(g, :player2, :square,5,5)

s = :sys.get_state(g)
s = :sys.replace_state(g, fn s -> %{s | rules: %Rules{state: :player1_turn}} end)

Game.set_islands(g, :player1)
Game.set_islands(g, :player2)

Game.guess_coordinate(g, :player1, 1,1)
"""
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  alias Islands.{Island, Board, Coordinate, Guesses, Rules}

  @players [:player1, :player2]

  @timeout 60 * 24 * 1000

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  def position_island(game, player, key, row, col) when player in @players do
    GenServer.call(game, {:position_island, player, key, row, col})
  end

  def set_islands(game, player) when player in @players do
    GenServer.call(game, {:set_islands, player})
  end

  def guess_coordinate(game, player, row, col) when player in @players do
    GenServer.call(game, {:guess_coordinate, player, row, col})
  end

  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}


  # GenServer Callbacks

  def init(name) do
    send(self(), {:set_state, name})  # this will return from the blocked init immediately
    {:ok, empty_game_state(name)}
  end

  def handle_call({:add_player, name}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, :add_player)
    do
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
    with {:ok, rules}       <- Rules.check(state.rules, {:position_islands, player}),
         {:ok, coordinate}  <- Coordinate.new(row, col),
         {:ok, island}      <- Island.new(key, coordinate),
         %{} = board        <- Board.position_island(board, key, island)
     do
       state
       |> update_board(player, board)
       |> update_rules(rules)
       |> reply_success(:ok)
     else
       :error                           -> reply_error(:error, state)
       {:error, :invalid_coordinate}    -> reply_error({:error, :invalid_coordinate}, state)
       {:error, :invalid_island_type}   -> reply_error({:error, :invalid_island_type}, state)
     end
  end
  def handle_call({:set_islands, player}, _from, state) do
    board = player_board(state, player)
    with {:ok, rules}   <- Rules.check(state.rules, {:set_islands, player}),
          true          <- Board.all_islands_positioned?(board)
    do
      state
      |> update_rules(rules)
      |> reply_success({:ok, board})
    else
      :error      -> reply_error(:error, state)
      false       -> reply_error({:error, :not_all_islands_positioned}, state)
    end
  end

  def handle_call({:guess_coordinate, player, row, col}, _from, state) do
    board = player_board(state, player)
    opponent_board = player_board(state, opponent(player))
    with {:ok, rules}        <- Rules.check(state.rules, {:guess_coordinate, player}),
         {:ok, coordinate}   <- Coordinate.new(row, col),
         {hit_miss, forested_island, win_status, opponent_board} <- Board.guess(opponent_board, coordinate),
         {:ok, rules}        <- Rules.check(rules, {:win_check, win_status})
    do
      state
      |> update_board(opponent(player), opponent_board)
      |> update_guesses(player, hit_miss, coordinate)
      |> update_rules(rules)
      |> reply_success({hit_miss, forested_island, win_status})
    else
      :error                           -> reply_error(:error, state)
      {:error, :invalid_coordinate}    -> reply_error({:error, :invalid_coordinate}, state)
    end
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end
  def handle_info({:set_state, name}, _state) do
    state =
      case :ets.lookup(:game_state, name) do
        []             -> empty_game_state(name)
        [{key, state}] -> state
      end
    :ets.insert(:game_state, {name, state})
    {:noreply, state, @timeout}
  end

  def terminate({:shutdown, :timeout}, state) do
    :ets.delete(:game_state, state.player1.name)
    :ok
  end
  def terminate(_reason, _state), do: :ok

  defp player_board(state, player), do: Map.get(state, player).board

  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1

  defp update_player2_name(state, name), do: put_in(state.player2.name, name)

  defp update_board(state, player, board), do: Map.update!(state, player, fn player -> %{player | board: board} end)

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp update_guesses(state, player, hit_miss, coordinate) do
    update_in(state[player].guesses, fn guesses -> Guesses.add(guesses, hit_miss, coordinate) end)
  end

  defp empty_game_state(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    %{player1: player1, player2: player2, rules: %Rules{}}
  end

  defp reply_success(state, reply) do
    :ets.insert(:game_state, {state.player1.name, state})
    {:reply, reply, state, @timeout}
  end

  defp reply_error(error, state), do: {:reply, error, state, @timeout}


end
