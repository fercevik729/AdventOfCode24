defmodule Day2 do
  @moduledoc """
  Documentation for `Day2`.
  """
  def main(filename) do
    reports =
      File.stream!(filename)
      |> Enum.map(fn report ->
        report
        |> String.trim()
        |> String.split(~r/\s+/)
        |> Enum.map(&String.to_integer/1)
      end)

    # Record the difference between each level in a particular report

    {part1(reports), part2(reports)}
  end

  def check_monotonicity(list) do
    start = hd(list)

    # Adjust the condition depending on the start value
    # We want to ensure that the entire report is monotonic + or - and delta is within [1, 3]
    condition =
      case start do
        start when start <= 0 ->
          &(&1 <= -1 && &1 >= -3)

        _ ->
          &(&1 >= 1 && &1 <= 3)
      end

    Enum.all?(list, condition)
  end

  def create_differences(list) do
    Enum.zip(list, tl(list))
    |> Enum.map(&(elem(&1, 1) - elem(&1, 0)))
  end

  def part1(reports) do
    # For each report
    # Check that levels in the report are monotonically + or - by at least 1 and at most 3
    # If the report doesn't meet above 2 conditions => unsafe, else => safe
    # Accumulate # of safe reports
    reports
    |> Enum.map(&create_differences(&1))
    |> Enum.filter(&check_monotonicity(&1))
    |> Enum.count()
  end

  def part2(reports) do
    reports
    |> Enum.filter(fn report ->
      safe =
        report
        |> create_differences()
        |> check_monotonicity()

      if safe do
        safe
      else
        # For each level, try removing it and computing the differences
        # Then check to see if this modified report is "safe"
        Enum.map(0..(length(report) - 1), fn idx ->
          {left, right} = Enum.split(report, idx)
          (left ++ tl(right)) |> create_differences()
        end)
        |> Enum.any?(&check_monotonicity(&1))
      end
    end)
    |> Enum.count()
  end
end
