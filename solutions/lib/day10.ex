defmodule Day10 do
  import Utils.Grid

  def main(filename) do
    grid =
      File.stream!(filename)
      |> Enum.map(fn line ->
        String.trim(line) |> String.graphemes() |> Enum.map(&String.to_integer/1)
      end)

    {part1(grid), part2(grid)}
  end

  def part1(grid) do
    # DFS from each trailhead to find all reachable 9's
    find_trailheads(grid)
    |> Enum.map(fn trailhead -> dfs(grid, trailhead, -1) |> MapSet.size() end)
    |> Enum.sum()
  end

  def part2(grid) do
    # DFS from each trailhead to find all reachable 9's
    find_trailheads(grid)
    |> Enum.map(fn trailhead -> dfs_2(grid, trailhead, -1) end)
    |> Enum.sum()
  end

  def dfs(grid, pos, prev) do
    case out_of_bounds?(grid, pos) do
      true ->
        MapSet.new()

      false ->
        curr = val(grid, pos)

        if curr != prev + 1 do
          MapSet.new()
        else
          case curr do
            9 ->
              MapSet.new([pos])

            _ ->
              directions()
              |> Enum.map(fn direction -> dfs(grid, get_next(pos, direction), curr) end)
              |> Enum.reduce(MapSet.new(), &MapSet.union/2)
          end
        end
    end
  end

  def dfs_2(grid, pos, prev) do
    case out_of_bounds?(grid, pos) do
      true ->
        0

      false ->
        curr = val(grid, pos)

        if curr != prev + 1 do
          0
        else
          case curr do
            9 ->
              1

            _ ->
              directions()
              |> Enum.map(fn direction -> dfs_2(grid, get_next(pos, direction), curr) end)
              |> Enum.sum()
          end
        end
    end
  end

  defp find_trailheads(grid) do
    Enum.with_index(grid)
    |> Enum.reduce([], fn {row, r}, acc ->
      Enum.with_index(row)
      |> Enum.reduce(acc, fn {val, c}, acc_ ->
        case val do
          0 -> acc_ ++ [{r, c}]
          _ -> acc_
        end
      end)
    end)
  end
end
