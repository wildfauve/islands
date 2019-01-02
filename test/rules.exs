defmodule RulesTest do
  use ExUnit.Case
  doctest Islands

  alias Islands.{Rules}

  test "initial state" do
    rules = Rules.new()

    assert rules.state == :initialised
  end

  test "add player sets the state to players_set" do
    rules = Rules.new()

    {:ok, rules} = Rules.check(rules, :add_player)

    assert rules.state == :players_set
  end


  test "position islands transitions to players_set" do
    rules = Rules.new()

    {:ok, rules} = Rules.check(rules, :add_player)

    {:ok, rules} = Rules.check(rules, {:position_islands, :player1})

    assert rules.state == :players_set
  end

  test "when islands are set for both players the state changes to player 1 turn" do
    rules = Rules.new()

    {:ok, rules} = Rules.check(rules, :add_player)

    {:ok, rules} = Rules.check(rules, {:position_islands, :player1})

    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})

    assert rules.state == :player1_turn
  end

  test "when player1 has a turn the state will be player 2 turn" do

    rules = Rules.new()

    rules = %{rules | state: :player1_turn}

    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})

    assert rules.state == :player2_turn

  end



end
