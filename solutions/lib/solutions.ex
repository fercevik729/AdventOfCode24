defmodule Solutions do
  @moduledoc """
  Documentation for `Solutions`.
  """
  @current_day 8

  def run_one(day) when day < 1 do
    IO.puts("Day #{day} is not a valid day!")
  end

  def run_one(day) when day > @current_day do
    IO.puts("Day #{day} has not been released yet!")
  end

  def run_one(day) do
    module_name = "Day#{day}"
    module = String.to_existing_atom("Elixir.#{module_name}")
    {part1, part2} = module.main("inputs/day#{day}.txt")
    IO.puts("Day #{day} Part 1: #{part1}, Part2: #{part2}")
  end

  def all() do
    for d <- 1..@current_day, do: run_one(d)
    IO.puts("All done!")
  end
end
