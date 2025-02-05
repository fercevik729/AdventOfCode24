defmodule Day9 do
  import Utils.Misc

  def main(filename) do
    input =
      File.read!(filename)
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()

    {part1(input), part2(input)}
  end

  def part2(input) do
    # We want to move each file starting from the file with the greatest id, at most 1x to the left
    # to a block of contiguous free space >= size of file
    # We need to be able to handle remainders of the free space
    # IDEA: map starting idx -> {val, offset }

    {_, _, diskmap} =
      Enum.reduce(input, {0, 0, %{}}, fn {x, idx}, {id, pos, disk} ->
        new_id = if rem(idx, 2) == 0, do: id + 1, else: id

        val = if rem(idx, 2) == 0, do: id, else: -1
        {new_id, pos + x, Map.put(disk, pos, {val, x})}
      end)

    to_swap =
      diskmap
      |> Map.keys()
      |> Enum.filter(fn x -> Map.get(diskmap, x) |> elem(0) != -1 end)
      |> Enum.sort()
      |> Enum.reverse()

    compmap =
      Enum.reduce(to_swap, diskmap, &swap_with_leftmost/2)

    Map.keys(compmap)
    |> Enum.reduce(0, fn pos, acc ->
      {id, offset} = Map.get(compmap, pos)

      case id do
        -1 -> acc
        _ -> pos..(pos + offset - 1) |> Enum.reduce(acc, fn val, sum -> sum + id * val end)
      end
    end)
  end

  defp swap_with_leftmost(blockpos, diskmap) do
    {id, blocksize} = Map.get(diskmap, blockpos)

    target =
      diskmap
      |> Map.keys()
      |> Enum.sort()
      |> Enum.drop_while(fn key ->
        {val, bsize} = Map.get(diskmap, key)
        key > blockpos or val != -1 or bsize < blocksize
      end)
      |> List.first()

    case target do
      nil ->
        diskmap

      _ ->
        {_, free_space} = Map.get(diskmap, target)
        diff = free_space - blocksize

        newmap =
          Map.put(diskmap, blockpos, {-1, blocksize}) |> Map.put(target, {id, blocksize})

        # Handle case for which free space > block size
        if diff > 0, do: Map.put(newmap, target + blocksize, {-1, diff}), else: newmap
    end
  end

  def part1(input) do
    {_, filemap} =
      Enum.reduce(input, {0, []}, fn {x, idx}, {id, fm} ->
        new_id = if rem(idx, 2) == 0, do: id + 1, else: id

        (fm ++
           case rem(idx, 2) do
             0 -> repeat_n(id, x)
             1 -> repeat_n(-1, x)
           end)
        |> then(fn x -> {new_id, x} end)
      end)

    Enum.with_index(filemap)
    |> Enum.filter(&(elem(&1, 0) == -1))
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce_while(filemap, fn blank_idx, acc ->
      {_, idx} = find_last_idx(acc, fn x -> x != -1 end)

      cond do
        idx <= blank_idx -> {:halt, acc}
        idx > blank_idx -> {:cont, swap_elements(acc, blank_idx, idx)}
      end
    end)
    |> Enum.filter(fn x -> x != -1 end)
    |> Enum.with_index()
    |> Enum.map(fn {val, idx} -> val * idx end)
    |> Enum.sum()
  end

  def find_last_idx(enumerable, pred) do
    Enum.with_index(enumerable)
    |> Enum.reverse()
    |> Enum.find(fn {x, _} -> pred.(x) end)
  end

  def swap_elements(list, index1, index2) do
    list
    |> Enum.with_index()
    |> Enum.map(fn
      {_, ^index1} -> Enum.at(list, index2)
      {_, ^index2} -> Enum.at(list, index1)
      {elem, _} -> elem
    end)
  end
end
