defmodule TopSort do
  def sort(edges) do
    {graph, in_degrees} = build_graph(edges)

    sources =
      Enum.filter(in_degrees, fn {_, degrees} -> degrees == 0 end) |> Enum.map(&elem(&1, 0))

    topological_sort(graph, in_degrees, sources, [])
    |> Enum.reverse()
  end

  defp build_graph(edges) do
    Enum.reduce(edges, {%{}, %{}}, fn {from, to}, {graph, in_degrees} ->
      graph = Map.update(graph, from, [to], &[to | &1])
      in_degrees = Map.update(in_degrees, to, 1, &(&1 + 1))
      in_degrees = Map.update(in_degrees, from, 0, & &1)
      {graph, in_degrees}
    end)
  end

  defp topological_sort(_, _, [], result), do: result

  defp topological_sort(graph, in_degrees, [source | sources], result) do
    new_result = [source | result]

    in_degrees = Map.delete(in_degrees, source)

    {graph, in_degrees} =
      Enum.reduce(graph[source] || [], {graph, in_degrees}, fn neighbor, {g, deg} ->
        deg = Map.update(deg, neighbor, 0, &(&1 - 1))
        {g, deg}
      end)

    new_sources =
      Enum.filter(in_degrees, fn {_, degree} -> degree == 0 end) |> Enum.map(&elem(&1, 0))

    in_degrees =
      Enum.reduce(new_sources, in_degrees, fn source, acc ->
        Map.delete(acc, source)
      end)

    topological_sort(graph, in_degrees, sources ++ new_sources, new_result)
  end
end

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

  def main do
    {_, rules, updates} =
      File.stream!("input.txt")
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
