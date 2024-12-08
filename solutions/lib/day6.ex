defmodule Day6 do
  alias Utils.Grid

  def main(filename) do
    grid =
      File.stream!(filename)
      |> Enum.map(fn line ->
        String.trim(line) |> String.to_charlist()
      end)

    {part1(grid), part2(grid)}
  end

  def part2(grid) do
    start_pos = Grid.find(grid, ?^)
    {_, moves} = get_guard_moves(MapSet.new(), grid, {MapSet.new([start_pos]), start_pos, :up})

    Enum.map(moves, fn {r, c} ->
      if Grid.val(grid, {r, c}) == ?^ do
        0
      else
        is_cycle(grid, {r, c}, start_pos)
      end
    end)
    |> Enum.sum()
  end

  def is_cycle(grid, {r, c}, start_pos) do
    grid = Grid.update(grid, {r, c}, ?#)

    {status, _} =
      get_guard_moves(
        MapSet.new([{start_pos, :up}]),
        grid,
        {MapSet.new([start_pos]), start_pos, :up}
      )

    if status == :cycle, do: 1, else: 0
  end

  def part1(grid) do
    start_pos = Grid.find(grid, ?^)
    visited = MapSet.new([start_pos])
    {_, moves} = get_guard_moves(MapSet.new([{start_pos, :up}]), grid, {visited, start_pos, :up})
    Enum.count(moves)
  end

  def get_guard_moves(seen_states, grid, {visited, {r, c}, direction}) do
    next =
      case direction do
        :up -> {r - 1, c}
        :down -> {r + 1, c}
        :right -> {r, c + 1}
        :left -> {r, c - 1}
      end

    if Grid.out_of_bounds?(grid, next) do
      {:ok, visited}
    else
      if Grid.val(grid, next) == ?# do
        get_guard_moves(seen_states, grid, {visited, {r, c}, rotate(direction)})
      else
        next_visited = MapSet.put(visited, next)
        next_state = {next, direction}

        # Check if we've been at this state before, if so we have a cycle
        if MapSet.member?(seen_states, next_state) do
          {:cycle, visited}
        else
          get_guard_moves(
            MapSet.put(seen_states, next_state),
            grid,
            {next_visited, next, direction}
          )
        end
      end
    end
  end

  defp rotate(:up), do: :right
  defp rotate(:right), do: :down
  defp rotate(:down), do: :left
  defp rotate(:left), do: :up
end
