defmodule Day3 do
  @mul_regex ~r/mul\((\d{1,3}),(\d{1,3})\)/
  @toggle_regex ~r/(do\(\)|don't\(\))/

  def driver() do
    input =
      File.read!("input.txt")
      |> String.replace(~r/\R/, "")

    {part1(input), part2(input)}
  end

  def part1(input) do
    Regex.scan(@mul_regex, input)
    |> Enum.map(fn [_, x, y] -> String.to_integer(x) * String.to_integer(y) end)
    |> Enum.sum()
  end

  def part2(line) do
    toggles = Regex.scan(@toggle_regex, line, return: :index)
    ops = Regex.scan(@mul_regex, line, return: :index)
    Enum.reduce(ops, 0, fn match, acc ->
      {start_match_idx, _} = hd(match)

      # Find the closest toggle to the current "mul" operation
      # Determine whether or not to enable it
      temp = Enum.take_while(toggles, fn [{t_idx, _}, _] -> t_idx < start_match_idx end)

      enabled =
        if length(temp) > 0 do
          [{_, t_length}, _] = Enum.at(temp, -1)
          t_length == 4
        else
          true
        end

      if enabled do
        {f_idx, f_len} = Enum.at(match, 1)
        {s_idx, s_len} = Enum.at(match, 2)
        x = String.slice(line, f_idx, f_len)
        y = String.slice(line, s_idx, s_len)
        acc + String.to_integer(x) * String.to_integer(y)
      else
        acc
      end
    end)
  end
end
