defmodule IslandTest do
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

    assert msg == :invalid_island_type
  end

  test "island goes off the board" do
    {:ok, coord1} = Coordinate.new(10,10)

    {:error, msg} = Island.new(:square, coord1)

    assert msg == :invalid_coordinate

  end

  test "islands which overlap" do
    {:ok, coord1} = Coordinate.new(1,1)
    {:ok, coord2} = Coordinate.new(2,1)

    {:ok, square_island} = Island.new(:square, coord1)
    {:ok, s_island} = Island.new(:s_shape, coord2)

    overlapped? = Island.overlap?(square_island, s_island)

    assert overlapped? == true
  end

  test "islands which do not overlap" do
    {:ok, coord1} = Coordinate.new(1,1)
    {:ok, coord2} = Coordinate.new(3,3)

    {:ok, square_island} = Island.new(:square, coord1)
    {:ok, dot_island} = Island.new(:dot, coord2)

    overlapped? = Island.overlap?(square_island, dot_island)

    assert overlapped? == false

  end

  test "adds a correct guess to the islands hits" do
    {:ok, coord1} = Coordinate.new(1,1)

    {:ok, guessed_coord} = Coordinate.new(2,2)

    {:ok, island} = Island.new(:square, coord1)

    {:hit, hits} = Island.guess(island, guessed_coord)

    assert MapSet.equal?(hits.hit_coordinates, MapSet.new([guessed_coord]))

  end

  test "returns :miss when the guess is incorrect" do
    {:ok, coord1} = Coordinate.new(1,1)

    {:ok, guessed_coord} = Coordinate.new(3,3)

    {:ok, island} = Island.new(:square, coord1)

    assert Island.guess(island, guessed_coord) == :miss

  end

  test "island is forested?" do

    {:ok, coord1} = Coordinate.new(1,1)

    {:ok, island} = Island.new(:square, coord1)

    {:ok, coord1} = Coordinate.new(1,1)
    {:ok, coord2} = Coordinate.new(1,2)
    {:ok, coord3} = Coordinate.new(2,1)
    {:ok, coord4} = Coordinate.new(2,2)

    {:hit, island} = Island.guess(island, coord1)
    {:hit, island} = Island.guess(island, coord2)
    {:hit, island} = Island.guess(island, coord3)
    {:hit, island} = Island.guess(island, coord4)

    assert Island.forested?(island) == true


  end


end
