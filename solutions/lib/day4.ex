defmodule DirectionEnum do
  @direction [
    :up,
    :down,
    :left,
    :right,
    :upperLeftDiag,
    :upperRightDiag,
    :lowerLeftDiag,
    :lowerRightDiag
  ]
  def all, do: @direction
end

defmodule Dfs do
  import Utils.Grid

  defp check_next_val("X", "M"), do: true
  defp check_next_val("M", "A"), do: true
  defp check_next_val("A", "S"), do: true
  defp check_next_val(_, _), do: false

  defp get_next_pos({r, c}, :up), do: {r - 1, c}
  defp get_next_pos({r, c}, :down), do: {r + 1, c}
  defp get_next_pos({r, c}, :left), do: {r, c - 1}
  defp get_next_pos({r, c}, :right), do: {r, c + 1}
  defp get_next_pos({r, c}, :upperLeftDiag), do: {r - 1, c - 1}
  defp get_next_pos({r, c}, :upperRightDiag), do: {r - 1, c + 1}
  defp get_next_pos({r, c}, :lowerLeftDiag), do: {r + 1, c - 1}
  defp get_next_pos({r, c}, :lowerRightDiag), do: {r + 1, c + 1}

  # Recursive DFS
  defp dfs(grid, {x, y}, direction) do
    {next_x, next_y} = get_next_pos({x, y}, direction)
    next_pos = {next_x, next_y}

    if out_of_bounds?(grid, next_pos) do
      0
    else
      curr_val = Enum.at(grid, x) |> Enum.at(y)
      next_val = Enum.at(grid, next_x) |> Enum.at(next_y)

      # Make sure the order of the letters are correct
      # If not: stop
      if check_next_val(curr_val, next_val) do
        case next_val do
          "S" -> 1
          _ -> dfs(grid, next_pos, direction)
        end
      else
        0
      end
    end
  end

  # Public function to invoke
  def driver(grid, {x, y}) do
    char = Enum.at(grid, x) |> Enum.at(y)

    if char != "X" do
      0
    else
      DirectionEnum.all()
      |> Enum.map(&dfs(grid, {x, y}, &1))
      |> Enum.sum()
    end
  end
end

defmodule XSearch do
  import Utils.Grid

  def is_x?(grid, {x, y}) do
    if Enum.at(grid, x) |> Enum.at(y) != "A" do
      false
    else
      check_vertical(grid, {x, y}) or check_horizontal(grid, {x, y})
    end
  end

  defp check_vals(grid, vals) do
    [a1, a2, b1, b2] = vals

    # Make sure the corners of the X are in bounds and not
    # X or A
    if(
      Enum.any?([a1, a2, b1, b2], fn {x, y} ->
        invalid = out_of_bounds?(grid, {x, y})

        if invalid do
          invalid
        else
          v = val(grid, {x, y})
          v == "X" or v == "A"
        end
      end)
    ) do
      false
    else
      # Make sure the two on each side are the same and either M or S
      cond1 = val(grid, a1) == val(grid, a2)
      cond2 = val(grid, b1) == val(grid, b2)
      cond3 = val(grid, a1) != val(grid, b1)
      cond1 and cond2 and cond3
    end
  end

  defp check_horizontal(grid, {x, y}) do
    l1 = {x - 1, y - 1}
    l2 = {x + 1, y - 1}

    r1 = {x - 1, y + 1}
    r2 = {x + 1, y + 1}

    check_vals(grid, [l1, l2, r1, r2])
  end

  defp check_vertical(grid, {x, y}) do
    u1 = {x - 1, y + 1}
    u2 = {x - 1, y - 1}

    d1 = {x + 1, y - 1}
    d2 = {x + 1, y + 1}

    check_vals(grid, [u1, u2, d1, d2])
  end
end

defmodule Day4 do
  def main(filename) do
    grid =
      File.stream!(filename)
      |> Enum.map(fn line ->
        String.trim(line) |> String.graphemes()
      end)

    xrange = 0..(length(grid) - 1)
    yrange = 0..(length(List.first(grid)) - 1)

    {part1(grid, xrange, yrange), part2(grid, xrange, yrange)}
  end

  def part1(grid, xrange, yrange) do
    counts =
      for x <- xrange,
          y <- yrange,
          do: Dfs.driver(grid, {x, y})

    Enum.sum(counts)
  end

  def part2(grid, xrange, yrange) do
    xs =
      for x <- xrange,
          y <- yrange,
          do: XSearch.is_x?(grid, {x, y})

    Enum.count(xs, fn elem -> elem end)
  end
end
