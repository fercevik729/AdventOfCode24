defmodule Day12 do
  import Utils.Grid

  def main(filename) do
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

    {_, p1_score, p2_score} =
      Enum.reduce(initial, {visited, 0, 0}, fn point, {vis, acc1, acc2} ->
        case MapSet.member?(vis, point) do
          true ->
            {vis, acc1, acc2}

          false ->
            {neighbors, p1, p2} =
              dfs(garden, point, %{}, %{})
              |> compute_scores()

            {MapSet.union(vis, neighbors), acc1 + p1, acc2 + p2}
        end
      end)

    {p1_score, p2_score}
  end

  def dfs(garden, pos, map, edges) do
    curr = val(garden, pos)

    adj =
      directions()
      |> Enum.map(fn dir -> get_next(pos, dir) end)
      |> Enum.filter(fn x ->
        !out_of_bounds?(garden, x) && val(garden, x) == curr
      end)

    map = Map.put(map, pos, length(adj))
    edges = Map.put(edges, pos, count_corners(garden, pos))
    next = Enum.filter(adj, fn x -> !Map.has_key?(map, x) end)

    Enum.reduce(next, {map, edges}, fn nextpos, {acc, acc2} ->
      {new_map, new_edges} = dfs(garden, nextpos, acc, acc2)
      {Map.merge(acc, new_map), Map.merge(acc2, new_edges)}
    end)
  end

  def compute_scores({map, edges}) do
    keys = Map.keys(map) |> MapSet.new()
    # Use perimeter for part1
    p1_score = (Map.values(map) |> Enum.map(&(4 - &1)) |> Enum.sum()) * map_size(map)
    # Use edges for part2
    p2_score = map_size(map) * (Map.values(edges) |> Enum.sum())
    {keys, p1_score, p2_score}
  end

  @doc ~S"""
  Counts the number of corners that occurs at a particular position in the grid
  by iterating over all 4 cardinal diagonals. Helpful for counting the total number
  of edges formed by a region, since # of corners = # of edges.
  """
  def count_corners(garden, pos) do
    curr = safe_val(garden, pos)

    diagonals()
    |> Enum.reduce(0, fn
      d, acc ->
        next = get_next(pos, d) |> then(fn x -> safe_val(garden, x) end)

        acc +
          case(d) do
            :upleft -> is_corner?(garden, pos, :up, :left, curr, next)
            :upright -> is_corner?(garden, pos, :up, :right, curr, next)
            :downleft -> is_corner?(garden, pos, :down, :left, curr, next)
            :downright -> is_corner?(garden, pos, :down, :right, curr, next)
          end
    end)
  end

  @doc ~S"""
  Checks if a position in a grid has a concave or convex corner in a particular direction

  For example:

  In:
  ```
    ? B
    B A <--- pos
  ```
  There is a `convex` corner in the upper-left direction at `pos`, assuming that B != A.
  The value in the upper-left does not matter and can even be equal to A, but will be regarded as its own region

  In:
  ```
    B A
    A A <---- pos
  ```
  There is a `concave` corner in the upper-left direction at the `pos`. The value in the upper left
  position `must` be different than `pos`

  """
  def is_corner?(garden, pos, d1, d2, curr, next) do
    v1 = safe_val(garden, get_next(pos, d1))
    v2 = safe_val(garden, get_next(pos, d2))
    is_concave = v1 != curr and v2 != curr
    is_convex = v1 == v2 and v1 == curr and curr != next

    res = is_concave or is_convex

    if res, do: 1, else: 0
  end
end
