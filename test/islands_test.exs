defmodule IslandsTest do
  use ExUnit.Case
  doctest Islands

  alias Islands.{Coordinate,Island}

  test "create an square island" do

    {:ok, coord1} = Coordinate.new(1,1)
    {:ok, coord2} = Coordinate.new(1,2)
    {:ok, coord3} = Coordinate.new(2,1)
    {:ok, coord4} = Coordinate.new(2,2)

    {:ok, island} = Island.new(:square, coord1)

    expected_result = MapSet.new([coord1,coord2,coord3,coord4])

    assert MapSet.equal?(island.coordinates, expected_result)

  end

  test "invalid island" do

    {:ok, coord1} = Coordinate.new(1,1)

    {:error, msg} = Island.new(:invalid_type, coord1)

    assert msg == :invalid_island
  end

  test "island goes off the board" do
    {:ok, coord1} = Coordinate.new(10,10)

    {:error, msg} = Island.new(:square, coord1)

    assert msg == :invalid_coordinate

  end

end
