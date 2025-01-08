defmodule Day18 do
  import Utils.Grid

  def bfs([], _, _, _, _), do: %{}

  def bfs([curr | rest_queue], walls, goal, cameFrom, dim) do
    case curr do
      ^goal ->
        cameFrom

      _ ->
        neighbors =
          directions()
          |> Enum.map(&get_next(curr, &1))
          |> Enum.filter(fn {r, c} ->
            cond do
              r < 0 or c < 0 or r >= dim or c >= dim -> false
              MapSet.member?(walls, {r, c}) -> false
              Map.has_key?(cameFrom, {r, c}) -> false
              true -> true
            end
          end)

        new_cm = Enum.reduce(neighbors, cameFrom, &Map.put(&2, &1, curr))
        new_queue = Enum.concat(rest_queue, neighbors)
        bfs(new_queue, walls, goal, new_cm, dim)
    end
  end

  def backtrack(_, {-1, -1}), do: 0

  def backtrack(cm, curr) do
    next = Map.get(cm, curr)
    1 + backtrack(cm, next)
  end

  def main(filename) do
    dim = 71
    kB = 1024

    all_corrupted =
      filename
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(fn x ->
        [c, r] =
          x
          |> String.trim()
          |> String.split(",")

        {String.to_integer(r), String.to_integer(c)}
      end)

    corrupted = Enum.take(all_corrupted, kB) |> MapSet.new()
    # IO.inspect(corrupted)
    rem_corrupted = Enum.drop(all_corrupted, kB)
    start = {0, 0}
    goal = {dim - 1, dim - 1}

    part1 =
      bfs([start], corrupted, goal, %{start => {-1, -1}}, dim)
      |> backtrack(goal)
      |> then(fn x -> x - 1 end)

    {_, {x, y}} =
      Enum.reduce_while(rem_corrupted, {corrupted, {-1, -1}}, fn {r, c}, {acc, _} ->
        new_acc = MapSet.put(acc, {r, c})
        # IO.puts("Dropping another corrupted block (#{r},#{c})")
        res = bfs([start], new_acc, goal, %{start => {-1, -1}}, dim)

        cond do
          map_size(res) > 0 -> {:cont, {new_acc, {-1, -1}}}
          true -> {:halt, {new_acc, {c, r}}}
        end
      end)

    part2 = "#{x},#{y}"

    {part1, part2}
  end
end
