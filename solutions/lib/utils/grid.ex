defmodule Utils.Grid do
  def out_of_bounds?(grid, {x, y}) do
    x < 0 or x >= length(grid) or y < 0 or y >= length(List.first(grid))
  end

  def val(grid, {x, y}) do
    Enum.at(grid, x) |> Enum.at(y)
  end
end
