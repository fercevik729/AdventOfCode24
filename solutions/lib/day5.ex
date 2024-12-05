
defmodule Day5 do
  @moduledoc """
  `Day5` Print Queue
  `Part1:` Use maps to store the indices of the numbers in the updates and check against the rules.
  `Part2:` Sort the invalid updates based on the rules and accumulate the midvals.
  """

  def str_to_num_list(str, pattern) do
    str
    |> String.split(pattern)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Check if the ordering of the indices is valid according to the rules
  """
  def valid_ordering?({num, idx}, map, rules) do
    keys = Map.keys(map)

    Enum.filter(rules, fn [dep, child] ->
      child == num and Enum.member?(keys, dep)
    end)
    |> Enum.all?(fn [dep, _] ->
      map[dep] < idx
    end)
  end

  def main(filename) do
    {_, rules, updates} =
      File.stream!(filename)
      |> Enum.reduce({:rules, [], []}, fn line, {mode, rs, us} ->
        line = String.trim(line)

        case {mode, line} do
          {:rules, ""} ->
            {:updates, rs, us}

          {:rules, l} ->
            {:rules,
             rs ++
               [str_to_num_list(l, "|")], []}

          {:updates, l} ->
            {:updates, rs, us ++ [str_to_num_list(l, ",")]}
        end
      end)

    Enum.reduce(updates, {0, 0}, fn update, {acc1, acc2} ->
      map =
        Enum.with_index(update)
        |> Enum.reduce(%{}, fn {num, idx}, acc ->
          Map.put(acc, num, idx)
        end)

      # PART 1: Accumulate the midvals of the valid orderings
      if Enum.with_index(update)
         |> Enum.all?(&valid_ordering?(&1, map, rules)) do
        {acc1 + Enum.at(update, div(length(update), 2)), acc2}
        # PART 2: Accumulate the midvals of the invalid orderings after sorting
      else
        Enum.sort(update, fn a, b -> Enum.member?(rules, [a, b]) end)
        |> Enum.at(div(length(update), 2))
        |> then(fn midval -> {acc1, acc2 + midval} end)
      end
    end)
  end
end
