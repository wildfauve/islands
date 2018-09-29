defmodule GuessesTest do
  use ExUnit.Case
  doctest Islands

  alias Islands.{Coordinate,Guesses}

  test "new guess" do

    %Guesses{hits: hits, misses: misses} = Guesses.new

    assert hits == MapSet.new
    assert misses == MapSet.new

  end

  test "add hits" do

    {:ok, coord1} = Coordinate.new(1,1)

    guesses = Guesses.new

    %Guesses{hits: hits, misses: misses} = Guesses.add(guesses, :hit, coord1)

    assert MapSet.member?(hits, coord1)

    assert MapSet.equal?(misses, MapSet.new([]))

  end


end
