defmodule Islands.Rules do
  alias __MODULE__

  defstruct [state: :initialised, player1: :island_not_set, player2: :island_not_set  ]

  def new(), do: %Rules{}

  def check(%Rules{state: :initialised} = rules, :add_player), do: {:ok, %Rules{rules | state: :players_set}}
  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set     -> :error
      :island_not_set  -> {:ok, rules}
    end
  end
  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)
    case(both_players_set?(rules)) do
      true  -> {:ok, %Rules{rules | state: :player1_turn}}
      false -> {:ok, rules}
    end
  end
  def check(%Rules{state: :player1_turn} = rules, {:guess_coordinate, :player1}) do
    {:ok, %Rules{rules | state: :player2_turn}}
  end
  def check(%Rules{state: :player2_turn} = rules, {:guess_coordinate, :player2}) do
    {:ok, %Rules{rules | state: :player1_turn}}
  end
  def check(%Rules{state: :player1_turn} = rules, {:win_check,win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win    -> {:ok, %Rules{rules | state: :game_over}}
    end
  end
  def check(%Rules{state: :player2_turn} = rules, {:win_check,win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win    -> {:ok, %Rules{rules | state: :game_over}}
    end
  end
  def check(_state, _action), do: :error

  defp both_players_set?(rules) do
    rules.player1 == :islands_set && rules.player2 == :islands_set
  end

end
