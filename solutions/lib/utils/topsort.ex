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
