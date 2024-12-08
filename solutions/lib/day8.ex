defmodule Day8 do
  def compute_antinodes({x1, y1}, {x2, y2}, {rows, cols}) do
    dx = x1 - x2
    dy = y1 - y2

    c1 = {x1 + dx, y1 + dy}

    case c1 do
      {x, y} when x < 0 or x >= rows or y < 0 or y >= cols ->
        {:err, nil}

      _ ->
        {:ok, [c1]}
    end
  end

  def compute_all_antinodes({x1, y1}, {x2, y2}, {rows, cols}) do
    dx = x1 - x2
    dy = y1 - y2

    steps = 0..rows |> Enum.to_list()

    {:ok,
     Enum.reduce_while(steps, [], fn s, acc ->
       new_x = x1 + dx * s
       new_y = y1 + dy * s

       if new_x < 0 or new_x >= rows or new_y < 0 or new_y >= cols do
         {:halt, acc}
       else
         {:cont, acc ++ [{new_x, new_y}]}
       end
     end)}
  end

  def main(filename) do
    grid =
      File.stream!(filename)
      |> Enum.map(fn line ->
        String.trim(line) |> String.graphemes() |> Enum.with_index()
      end)
      |> Enum.with_index()

    {eval(grid, &compute_antinodes/3), eval(grid, &compute_all_antinodes/3)}
  end

  def eval(grid, compute_fn) do
    rows = length(grid)
    cols = length(elem(List.first(grid), 0))

    grid
    |> Enum.reduce(%{}, fn {row, row_idx}, acc ->
      Enum.reduce(row, acc, fn {val, col_idx}, row_acc ->
        case val do
          "." ->
            row_acc

          _ ->
            Map.update(row_acc, val, [{row_idx, col_idx}], fn count ->
              count ++ [{row_idx, col_idx}]
            end)
        end
      end)
    end)
    |> Map.to_list()
    |> Enum.reduce(MapSet.new(), fn {_, coors}, acc ->
      pairs =
        for c1 <- coors,
            c2 <- coors,
            do: {c1, c2}

      new_acc =
        pairs
        |> Enum.to_list()
        |> Enum.reduce(acc, fn {c1, c2}, antinodes ->
          res =
            with true <- c1 != c2,
                 {:ok, val} <- compute_fn.(c1, c2, {rows, cols}),
                 do: Enum.reduce(val, antinodes, &MapSet.put(&2, &1))

          case res do
            false -> antinodes
            {:err, _} -> antinodes
            _ -> res
          end
        end)

      new_acc
    end)
    |> MapSet.size()
  end
end
