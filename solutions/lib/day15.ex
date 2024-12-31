defmodule Day15 do
  import Utils.Grid

  def part1(filename) do
    [grid, moves] =
      filename
      |> File.stream!()
      |> Enum.map(&String.trim/1)
      |> Enum.chunk_by(&(&1 == ""))
      |> List.delete_at(1)

    {_, warehouse} =
      Enum.reduce(grid, {0, %{}}, fn row, {r, acc} ->
        {_, acc} =
          row
          |> String.graphemes()
          |> Enum.reduce({0, acc}, fn elem, {c, map} ->
            key =
              case elem do
                "#" -> :wall
                "O" -> :box
                "@" -> :robot
                "." -> :free
              end

            {c + 1,
             Map.update(map, key, MapSet.new([{r, c}]), fn exist -> MapSet.put(exist, {r, c}) end)}
          end)

        {r + 1, acc}
      end)

    moves =
      Enum.join(moves, "")
      |> String.graphemes()

    Enum.reduce(moves, warehouse, &move_robot(&2, &1))
    |> Map.get(:box)
    |> MapSet.to_list()
    |> Enum.reduce(0, fn {r, c}, acc -> acc + r * 100 + c end)
  end

  def get_stack(warehouse, {r, c}, dir) do
    boxes = Map.get(warehouse, :box)
    max_stack = 1000

    {r_incr, c_incr} = get_next({0, 0}, dir)

    Enum.map(0..max_stack, &{&1 * r_incr + r, &1 * c_incr + c})
    |> Enum.take_while(&MapSet.member?(boxes, &1))
  end

  def print_warehouse(warehouse, max_rows, max_cols) do
    Enum.reduce(0..(max_rows - 1), "", fn r, output ->
      output <>
        Enum.reduce(0..(max_cols - 1), "", fn c, acc ->
          acc <>
            cond do
              Map.get(warehouse, :box) |> MapSet.member?({r, c}) ->
                "O"

              Map.get(warehouse, :free) |> MapSet.member?({r, c}) ->
                "."

              Map.get(warehouse, :robot) |> MapSet.member?({r, c}) ->
                "@"

              Map.get(warehouse, :wall) |> MapSet.member?({r, c}) ->
                "#"

              true ->
                ""
            end
        end) <> "\n"
    end)
    |> IO.puts()
  end

  def move_robot(warehouse, move) do
    direction =
      case move do
        "^" -> :up
        "v" -> :down
        "<" -> :left
        ">" -> :right
      end

    robot_pos = Map.get(warehouse, :robot) |> MapSet.to_list() |> List.first()
    next_pos = get_next(robot_pos, direction)

    cond do
      Map.get(warehouse, :wall) |> MapSet.member?(next_pos) ->
        warehouse

      Map.get(warehouse, :free) |> MapSet.member?(next_pos) ->
        Map.put(warehouse, :robot, MapSet.new([next_pos]))
        |> Map.update!(:free, fn curr ->
          MapSet.put(curr, robot_pos) |> MapSet.delete(next_pos)
        end)

      true ->
        after_stack =
          get_stack(warehouse, next_pos, direction)
          |> List.last()
          |> get_next(direction)

        # Robot can only move if there is at least one empty space after the stack
        if Map.get(warehouse, :free) |> MapSet.member?(after_stack) do
          Map.update!(warehouse, :box, fn curr ->
            curr
            |> MapSet.delete(next_pos)
            |> MapSet.put(after_stack)
          end)
          |> Map.update!(:free, fn curr ->
            curr
            |> MapSet.delete(after_stack)
            |> MapSet.put(robot_pos)
          end)
          |> Map.put(:robot, MapSet.new([next_pos]))
        else
          warehouse
        end
    end
  end
end
