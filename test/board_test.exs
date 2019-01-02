defmodule BoardTest do
  use ExUnit.Case
  doctest Islands

  alias Islands.{Board, Island, Coordinate}

  describe "positioning islands" do

    test "positions an island on the board" do
      board = Board.new()
      {:ok, coord1} = Coordinate.new(1,1)
      {:ok, island} = Island.new(:square, coord1)

      new_board = Board.position_island(board, :square, island)

      %Island{coordinates: island_coords, hit_coordinates: _} = Map.get(new_board, :square)

      assert MapSet.member?(island_coords, coord1)

    end

    test "doesnt allow including an overlapping island" do
      board = Board.new()
      {:ok, coord1} = Coordinate.new(1,1)
      {:ok, coord2} = Coordinate.new(2,1)
      {:ok, square_island} = Island.new(:square, coord1)
      {:ok, s_island} = Island.new(:s_shape, coord2)

      new_board = Board.position_island(board, :square, square_island)

      {:error, msg} = Board.position_island(new_board, :s_shape, s_island)

      assert msg == :overlapping_island
    end

  end

  describe "readying the board" do

    test "board positioning complete" do
      {:ok, sq_coord} = Coordinate.new(1,1)
      {:ok, s_coord}  = Coordinate.new(2,2)
      {:ok, l_coord}  = Coordinate.new(6,1)
      {:ok, d_coord}  = Coordinate.new(10,10)
      {:ok, a_coord}  = Coordinate.new(7,5)

      island_coords = [{:square, sq_coord}, {:s_shape, s_coord}, {:l_shape, l_coord}, {:dot, d_coord}, {:atoll, a_coord}]

      board = List.foldl(island_coords, Board.new, fn ({type, coord}, board) ->
        {:ok, island} = Island.new(type, coord)
        Board.position_island(board, type, island)
      end)

      assert Board.all_islands_positioned?(board) == true

    end

  end

  describe "guessing" do

    setup do

      {_ok, sq_coord} = Coordinate.new(1,1)
      {_ok, s_coord}  = Coordinate.new(2,2)
      {_ok, l_coord}  = Coordinate.new(6,1)
      {_ok, d_coord}  = Coordinate.new(10,10)
      {_ok, a_coord}  = Coordinate.new(7,5)

      island_coords = [{:square, sq_coord}, {:s_shape, s_coord}, {:l_shape, l_coord}, {:dot, d_coord}, {:atoll, a_coord}]

      board = List.foldl(island_coords, Board.new, fn ({type, coord}, board) ->
        {:ok, island} = Island.new(type, coord)
        Board.position_island(board, type, island)
      end)

      {:ok, board: board}

    end

    test "guessing correctly, forest the dot, tho not winning", %{board: board} do

      {:ok, guess1} = Coordinate.new(10,10)

      {:hit, :dot, :no_win, board} = Board.guess(board, guess1)

      dot_island = Map.get(board, :dot)

      assert MapSet.member?(dot_island.hit_coordinates, guess1)
    end

    test "missing", %{board: board} do

      {:ok, miss_guess} = Coordinate.new(9,9)

      assert {:miss, :none, :no_win, board} == Board.guess(board, miss_guess)

    end

    test "winning, all forested", %{board: board} do

      # cheat by setting most of the islands as hit.
      sq = board.square
      sq = %{ sq | hit_coordinates: sq.coordinates}
      board = Board.position_island(board, :square, sq)
      l = board.l_shape
      l = %{ l | hit_coordinates: l.coordinates}
      board = Board.position_island(board, :l_shape, l)
      s = board.s_shape
      s = %{ s | hit_coordinates: s.coordinates}
      board = Board.position_island(board, :s_shape, s)
      a = board.atoll
      a = %{ a | hit_coordinates: a.coordinates}
      board = Board.position_island(board, :atoll, a)

      {:ok, final_guess} = Coordinate.new(10,10)

      {:hit, :dot, :win, board} = Board.guess(board, final_guess)

      assert Board.all_forested?(board) == true

    end

  end

end
