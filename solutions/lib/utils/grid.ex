defmodule Utils.Grid do
  def out_of_bounds?(grid, {x, y}) do
    x < 0 or x >= length(grid) or y < 0 or y >= length(List.first(grid))
  end

  def val(grid, {x, y}) do
    Enum.at(grid, x) |> Enum.at(y)
  end

  def safe_val(grid, {x, y}) do
    case out_of_bounds?(grid, {x, y}) do
      true -> {:error, nil}
      _ -> {:ok, Enum.at(grid, x) |> Enum.at(y)}
    end
  end

  def find(grid, target) do
    Enum.with_index(grid)
    |> Enum.reduce_while(nil, fn {row, row_index}, _acc ->
      case Enum.find_index(row, &(&1 == target)) do
        nil -> {:cont, nil}
        col_index -> {:halt, {row_index, col_index}}
      end
    end)
  end

  def update(grid, {row, col}, value) do
    List.update_at(grid, row, fn row_list ->
      List.update_at(row_list, col, fn _ -> value end)
    end)
  end

  def directions(), do: [:up, :down, :left, :right]
  def diagonals(), do: [:upleft, :upright, :downleft, :downright]

  def rotations(dir_a, dir_b) when dir_a == dir_b, do: 0
  def rotations(:up, :down), do: 2
  def rotations(:down, :up), do: 2

  def rotations(:left, :right), do: 2
  def rotations(:right, :left), do: 2

  def rotations(_, _), do: 1

  def get_next(dir), do: get_next({0, 0}, dir)

  def get_next({r, c}, :up), do: {r - 1, c}
  def get_next({r, c}, :down), do: {r + 1, c}
  def get_next({r, c}, :left), do: {r, c - 1}
  def get_next({r, c}, :right), do: {r, c + 1}

  def get_next({r, c}, :upleft), do: {r - 1, c - 1}
  def get_next({r, c}, :upright), do: {r - 1, c + 1}
  def get_next({r, c}, :downleft), do: {r + 1, c - 1}
  def get_next({r, c}, :downright), do: {r + 1, c + 1}
end
