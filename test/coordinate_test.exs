defmodule CoordinateTest do
  use ExUnit.Case
  doctest Islands

  alias Islands.Coordinate

  test "valid coordinate" do

    {:ok, coord} = Coordinate.new(1,1)

    assert coord.row == 1
    assert coord.col == 1
  end

  test "outside coordinate range" do

    {:error, msg} = Coordinate.new(11,11)

    assert msg == :invalid_coordinate
  end


end
