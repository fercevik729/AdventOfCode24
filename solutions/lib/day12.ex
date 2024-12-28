defmodule Day12 do
  import Utils.Grid

  def part1(filename) do
    garden =
      File.stream!(filename)
      |> Enum.map(fn line ->
        String.trim(line)
        |> String.graphemes()
      end)

    rows = length(garden)
    cols = List.first(garden) |> length()

    initial =
      for(
        r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        do: {r, c}
      )
      |> MapSet.new()

    visited = MapSet.new()

    {_, score} =
      Enum.reduce(initial, {visited, 0}, fn point, {vis, acc} ->
        case MapSet.member?(vis, point) do
          true ->
            {vis, acc}

          false ->
            {neighbors, score} =
              dfs(garden, point, %{})
              |> extract()

            {MapSet.union(vis, neighbors), acc + score}
        end
      end)

    score
  end

  def dfs(garden, pos, map) do
    curr = val(garden, pos)

    adj =
      directions()
      |> Enum.map(fn dir -> get_next(pos, dir) end)
      |> Enum.filter(fn x ->
        !out_of_bounds?(garden, x) && val(garden, x) == curr
      end)

    map = Map.put(map, pos, length(adj))
    next = Enum.filter(adj, fn x -> !Map.has_key?(map, x) end)

    Enum.reduce(next, map, fn nextpos, acc ->
      Map.merge(acc, dfs(garden, nextpos, acc))
    end)
  end

  def extract(map) do
    keys = Map.keys(map) |> MapSet.new()
    score = (Map.values(map) |> Enum.map(&(4 - &1)) |> Enum.sum()) * map_size(map)
    # area = map_size(map)
    # score = perimeter * area
    # IO.inspect(map)
    # IO.puts("Computed region score of #{score} with perimeter=#{perimeter} & area=#{area}")
    {keys, score}
  end
end
