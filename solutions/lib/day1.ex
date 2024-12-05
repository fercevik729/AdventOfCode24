defmodule Day1 do
  @moduledoc """
  Documentation for `Day1`.
  """

  def main(filename) do
    {indices1, indices2} =
      File.stream!(filename)
      |> Enum.flat_map(fn line ->
        line
        |> String.trim()
        |> String.split(~r/\s+/)
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.with_index()
      |> Enum.split_with(fn {_, index} -> rem(index, 2) == 0 end)

    fst = Enum.map(indices1, fn {elem, _} -> elem end) |> Enum.sort()
    snd = Enum.map(indices2, fn {elem, _} -> elem end) |> Enum.sort()

    {part1(fst, snd), part2(fst, snd)}
  end

  def part1(s_fst, s_snd) do
    Enum.zip(s_fst, s_snd)
    |> Enum.reduce(0, fn {left, right}, acc -> acc + abs(left - right) end)
  end

  def part2(left, right) do
    similarity =
      Enum.reduce(left, %{}, fn l, acc_map ->
        Map.put(acc_map, l, 0)
      end)

    similarity =
      Enum.reduce(right, similarity, fn r, acc_map ->
        Map.update(acc_map, r, nil, fn val -> val + 1 end)
      end)

    Enum.reduce(similarity, 0, fn {key, value}, acc ->
      case value do
        nil -> acc
        _ -> acc + key * value
      end
    end)
  end
end
