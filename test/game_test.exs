defmodule IslandsEngine.GameTest do
  use ExUnit.Case

  alias IslandsEngine.Game

  @name "Betty"

  setup do
    {:ok, pid} = Game.start_link(@name)
    {:ok, game: pid}
  end

  test "should add player on game", %{game: game} do
    assert :ok == Game.add_player(game, "Barney")
  end

  test "should return error when player tries to guess twice", %{game: game} do
    :ok = Game.add_player(game, "Barney")
    :ok = Game.set_island_coordinates(game, :player1, :dot, [:a1])
    :ok = Game.set_island_coordinates(game, :player1, :atoll, [:a1])
    :ok = Game.set_island_coordinates(game, :player1, :l_shape, [:a1])
    :ok = Game.set_island_coordinates(game, :player1, :s_shape, [:a1])
    :ok = Game.set_island_coordinates(game, :player1, :square, [:a1])
    :ok = Game.set_islands(game, :player1)
    :ok = Game.set_islands(game, :player2)

    assert {:miss, :none, :no_win} = Game.guess_coordinate(game, :player1, :d1)
    assert {:error, :action_out_of_sequence} = Game.guess_coordinate(game, :player1, :d1)
  end
end
