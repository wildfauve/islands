defmodule Islands.Board do

  alias Islands.{Island, Coordinate}

  def new(), do: %{}

  def position_island(board, key, %Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true  -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  def all_islands_positioned?(board) do
    Enum.all?(Island.types, &(Map.has_key?(board, &1)))
  end

  def guess(board, %Coordinate{} = guess) do
    board
    |> check_all_islands(guess)
    |> guess_response(board)
  end


  def all_forested?(board), do: Enum.all?(board, fn {_key, island} -> Island.forested?(island) end)

  defp check_all_islands(board, guess) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, guess) do
        {:hit, island} -> { key, island}
        :miss          -> false
      end
    end)
  end

  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forested_check(board, key), win_check(board), board}
  end
  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  defp forested_check(board, key) do
    case forested?(board, key) do
      true  -> key
      false -> :none
    end
  end

  defp forested?(board, key) do
    board
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  defp win_check(board) do
    case all_forested?(board) do
      true  -> :win
      false -> :no_win
    end
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} -> key != new_key and Island.overlap?(island, new_island) end )
  end

end
