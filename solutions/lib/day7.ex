defmodule Day7 do
  def backtrack({res, ops}, fns), do: backtrack({res, ops}, Enum.at(ops, 0), 1, fns)

  def backtrack({res, ops}, acc, i, _) when i == length(ops), do: res == acc

  def backtrack({res, _}, acc, _, _) when acc > res, do: false

  def backtrack({res, ops}, acc, i, fns) do
    Enum.at(ops, i)
    |> then(fn x ->
      Enum.any?(Enum.map(fns, fn f -> backtrack({res, ops}, f.(acc, x), i + 1, fns) end))
    end)
  end

  def concat_digits(curr, new) do
    (Integer.to_string(curr) <> Integer.to_string(new))
    |> String.to_integer()
  end

  def main(filename) do
    lines =
      File.stream!(filename)
      |> Enum.map(fn line ->
        parts =
          line
          |> String.trim()
          |> String.split(":")

        res = Enum.at(parts, 0) |> String.to_integer()

        ops =
          Enum.at(parts, 1)
          |> String.trim()
          |> String.split(" ")
          |> Enum.map(&String.to_integer/1)

        {res, ops}
      end)

    fns = [&Kernel.+/2, &Kernel.*/2]
    {eval(lines, fns), eval(lines, fns ++ [&concat_digits/2])}
  end

  def eval(lines, fns) do
    lines
    |> Enum.filter(&backtrack(&1, fns))
    |> Enum.map(fn {res, _} -> res end)
    |> Enum.sum()
  end
end
