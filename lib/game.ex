defmodule IslandsEngine.Game do
  use GenServer
  alias IslandsEngine.{Game, Player, Coordinate, IslandSet, IslandSet}

  defstruct player1: :none, player2: :none

  # API

  def call_demo(game) do
    GenServer.call(game, :demo)
  end

  def start_link(name) when is_binary(name) and byte_size(name) > 0 do
    GenServer.start_link(__MODULE__, name, name: {:global, "game:#{name}"})
  end

  def add_player(pid, name) when not is_nil(name) do
    GenServer.call(pid, {:add_player, name})
  end

  def set_island_coordinates(pid, player, island, coordinates)
      when is_atom(player) and is_atom(island) do
    GenServer.call(pid, {:set_island_coordinates, player, island, coordinates})
  end

  def guess_coordinate(pid, player, coordinate) when is_atom(player) and is_atom(coordinate) do
    GenServer.call(pid, {:guess, player, coordinate})
  end

  # Callbacks

  def init(name) do
    {:ok, player1} = Player.start_link(name)
    {:ok, player2} = Player.start_link(name)
    {:ok, %Game{player1: player1, player2: player2}}
  end

  def handle_call({:add_player, name}, _from, state) do
    Player.set_name(state.player2, name)
    {:reply, :ok, state}
  end

  def handle_call({:set_island_coordinates, player, island, coordinates}, _from, state) do
    state
    |> Map.get(player)
    |> Player.set_island_coordinates(island, coordinates)

    {:reply, :ok, state}
  end

  def handle_call(:demo, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:guess, player, coordinate}, _from, state) do
    opponent = get_opponent(state, player)
    opponent_board = Player.get_board(opponent)

    Player.guess_coordinate(opponent_board, coordinate)
    |> forest_check(opponent, coordinate)
    |> win_check(opponent, state)
  end

  # Private

  defp get_opponent(state, :player1) do
    state.player2
  end

  defp get_opponent(state, :player2) do
    state.player1
  end

  defp forest_check(:miss, _opponent, _coordinate), do: {:miss, :none}

  defp forest_check(:hit, opponent, coordinate) do
    island_key = Player.forested_island(opponent, coordinate)
    {:hit, island_key}
  end

  defp win_check({hit_or_miss, :none}, _opponent, state) do
    {:reply, {hit_or_miss, :none, :no_win}, state}
  end

  defp win_check({:hit, island_key}, opponent, state) do
    win_status =
      case Player.win?(opponent) do
        true -> :win
        false -> :no_win
      end

    {:reply, {:hit, island_key, win_status}, state}
  end
end