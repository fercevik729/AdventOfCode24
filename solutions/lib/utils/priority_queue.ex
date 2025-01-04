defmodule Utils.PriorityQueue do
  @moduledoc """
  A simple implementation of a Priority Queue using a heap.
  """
  defstruct heap: []

  @doc """
  Creates an empty priority queue.
  """
  def new(), do: %__MODULE__{heap: []}

  def insert(%__MODULE__{heap: heap} = pq, priority, element) do
    new_heap = [{priority, element} | heap]
    %{pq | heap: Enum.sort(new_heap, &<=/2)}
  end

  def pop(%__MODULE__{heap: []}), do: {:error, :empty_queue}

  def pop(%__MODULE__{heap: [{_, element} | rest]}), do: {element, %__MODULE__{heap: rest}}

  def peek(%__MODULE__{heap: []}), do: {:error, :empty_queue}

  def peek(%__MODULE__{heap: [{_, element}]}), do: {:ok, element}

  def empty?(%__MODULE__{heap: heap}), do: heap == []

  def find(%__MODULE__{heap: heap}, elem), do: Enum.find(heap, fn {_, e} -> e == elem end)

  def update(%__MODULE__{heap: heap} = pq, new_priority, elem) do
    case find(pq, elem) do
      nil ->
        insert(pq, new_priority, elem)

      {old, _} when old < new_priority ->
        pq

      _ ->
        Enum.reduce(heap, [], fn {p, e}, acc ->
          acc ++
            case e do
              ^elem ->
                [{new_priority, e}]

              _ ->
                [{p, e}]
            end
        end)
        |> Enum.sort(&<=/2)
        |> then(fn x -> %__MODULE__{heap: x} end)
    end
  end
end
