defmodule Islands.GameSupervisor do

@moduledoc """
alias Islands.{Game, GameSupervisor}
{:ok, g} = GameSupervisor.start_game("Col")
via = Game.via_tuple("Col")

GenServer.whereis(via)

Supervisor.count_children(GameSupervisor)
Supervisor.which_children(GameSupervisor)

GameSupervisor.stop_game("Col")

"""
  use Supervisor

  alias Islands.Game

  def start_game(name) do
    Supervisor.start_child(__MODULE__, [name])
  end

  def stop_game(name) do
    :ets.delete(:game_state, name)
    Supervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  def start_link(_options) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Callbacks

  def init(:ok) do
    Supervisor.init([Game], strategy: :simple_one_for_one)
  end

  defp pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end


end
