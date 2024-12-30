defmodule Day14 do
  defmodule Robot do
    defstruct position: {0, 0}, velocity: {0, 0}

    def move_n(robot, n, max_x, max_y) do
      {px, py} = robot.position
      {vx, vy} = robot.velocity

      %Robot{
        robot
        | position: {(px + vx * n) |> Integer.mod(max_x), (py + vy * n) |> Integer.mod(max_y)}
      }
    end
  end

  def main(filename) do
    robots =
      filename
      |> File.stream!()
      |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.split(" ")
        |> Enum.reduce([], fn elem, acc ->
          String.split(elem, "=")
          |> Enum.at(1)
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
          |> List.to_tuple()
          |> then(&Enum.concat(acc, [&1]))
        end)
        |> then(fn [p, v] -> %Robot{position: p, velocity: v} end)
      end)

    {part1(robots, 100), part2(robots)}
  end

  defp print_robots(robots, rows, cols) do
    Enum.reduce(0..(rows - 1), "", fn r, output ->
      output <>
        Enum.reduce(0..(cols - 1), "", fn c, acc ->
          case MapSet.member?(robots, {r, c}) do
            true -> acc <> "X"
            false -> acc <> "."
          end
        end) <> "\n"
    end)
    |> IO.puts()
  end

  def part2(robots) do
    cols = 101
    rows = 103

    {iter, _} =
      0..10_000
      |> Enum.reduce({-1, 100_000_000_00}, fn iter, {min_iter, min_safety} ->
        safety = part1(robots, iter)

        if safety < min_safety do
          {iter, safety}
        else
          {min_iter, min_safety}
        end
      end)

    robots
    |> Enum.map(fn r ->
      %Robot{position: {x, y}} = Robot.move_n(r, iter, cols, rows)
      {y, x}
    end)
    |> MapSet.new()
    |> print_robots(rows, cols)

    iter
  end

  def part1(robots, n) do
    max_x = 101
    max_y = 103
    mid_x = floor(max_x / 2)
    mid_y = floor(max_y / 2)

    Enum.reduce(robots, %{}, fn r, acc ->
      %Robot{position: {x, y}} = Robot.move_n(r, n, max_x, max_y)

      cond do
        x < mid_x and y < mid_y ->
          Map.update(acc, 1, 1, fn ex -> ex + 1 end)

        x < mid_x and y > mid_y ->
          Map.update(acc, 2, 1, fn ex -> ex + 1 end)

        x > mid_x and y < mid_y ->
          Map.update(acc, 3, 1, fn ex -> ex + 1 end)

        x > mid_x and y > mid_y ->
          Map.update(acc, 4, 1, fn ex -> ex + 1 end)

        true ->
          acc
      end
    end)
    |> Map.values()
    |> Enum.reduce(1, &Kernel.*/2)
  end
end
