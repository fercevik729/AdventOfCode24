defmodule Day11 do
  def main(filename) do
    initial = File.read!(filename) |> String.split() |> Enum.map(&String.to_integer/1)
    cache = precompute(initial, %{})
    start = Map.from_keys(initial, 1)

    {driver(start, cache, 25), driver(start, cache, 75)}
  end

  defp driver(start, cache, blinks) do
    1..blinks
    |> Enum.reduce(start, fn _, prev ->
      Map.keys(prev)
      |> Enum.reduce(%{}, fn key, curr ->
        nextt = Map.get(cache, key)
        freq = Map.get(prev, key)

        Enum.reduce(nextt, curr, fn x, acc ->
          Map.update(acc, x, freq, fn exist -> exist + freq end)
        end)
      end)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  @doc ~S"""
  Computes a map of numbers -> subsequent numbers in the Plutonion sequence
  using DFS + memoization.
  """
  def precompute(list, cache) do
    Enum.reduce(list, cache, fn num, acc ->
      nextt = next_nums(num)
      acc = Map.put(acc, num, nextt)
      unseen = Enum.filter(nextt, fn x -> Map.get(acc, x) == nil end)
      Map.merge(acc, precompute(unseen, acc))
    end)
  end

  defp next_nums(0), do: [1]

  defp next_nums(num) do
    itoa = Integer.to_string(num)
    len = String.length(itoa)

    if rem(len, 2) == 0 do
      mid = div(len, 2)

      [
        String.slice(itoa, 0..(mid - 1)) |> String.to_integer(),
        String.slice(itoa, mid..(len - 1)) |> String.to_integer()
      ]
    else
      [num * 2024]
    end
  end
end
