defmodule Solutions do
  @moduledoc """
  Documentation for `Solutions`.
  """
  def current_day() do
    {:ok, dec1_midnight} = NaiveDateTime.new(2024, 12, 1, 0, 0, 0)
    dec1_midnight_utc = NaiveDateTime.add(dec1_midnight, 5 * 3600, :second)

    DateTime.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.diff(dec1_midnight_utc, :second)
    |> div(86_400)
    |> Kernel.+(1)
  end

  def run_one(day) when day < 1 do
    IO.puts("Day #{day} is not a valid day!")
  end

  def run_one(day) do
    if day > current_day() do
      IO.puts("Day #{day} has not been released yet!")
    else
      module_name = "Day#{day}"
      module = String.to_existing_atom("Elixir.#{module_name}")
      {part1, part2} = module.main("inputs/day#{day}.txt")
      IO.puts("Day #{day} Part 1: #{part1}, Part2: #{part2}")
    end
  end

  def all() do
    for d <- 1..current_day(), do: run_one(d)
    IO.puts("All done!")
  end
end
