defmodule Day15 do
  import Utils.Grid

  defmodule Part2 do
    defstruct boxes: %{}, robot: {0, 0}, walls: MapSet.new()

    defp move_double_box(
           %Part2{boxes: boxes} = warehouse,
           {{a_r, a_c} = a, {b_r, b_c} = b},
           dir
         ) do
      {r_offset, c_offset} = get_next(dir)
      new_a = {a_r + r_offset, a_c + c_offset}
      new_b = {b_r + r_offset, b_c + c_offset}

      boxes = if Map.get(boxes, a) == b, do: Map.delete(boxes, a)
      boxes = if Map.get(boxes, b) == a, do: Map.delete(boxes, b)

      boxes
      |> Map.put(new_a, new_b)
      |> Map.put(new_b, new_a)
      |> then(fn x ->
        %Part2{warehouse | boxes: x}
      end)
    end

    defp add_elem(warehouse, elem, {r, c}) do
      case elem do
        "#" ->
          %Part2{
            warehouse
            | walls: MapSet.put(warehouse.walls, {r, c}) |> MapSet.put({r, c + 1})
          }

        "O" ->
          %Part2{
            warehouse
            | boxes: Map.put(warehouse.boxes, {r, c}, {r, c + 1}) |> Map.put({r, c + 1}, {r, c})
          }

        "@" ->
          %Part2{
            warehouse
            | robot: {r, c}
          }

        "." ->
          warehouse
      end
    end

    defp display(warehouse, max_rows) do
      Enum.reduce(0..(max_rows - 1), "", fn r, output ->
        output <>
          Enum.reduce(0..(max_rows * 2 - 1), "", fn c, acc ->
            acc <>
              cond do
                Map.get(warehouse.boxes, {r, c}) != nil ->
                  prev = Map.get(warehouse.boxes, {r, c - 1})

                  if prev == {r, c} do
                    "]"
                  else
                    "["
                  end

                MapSet.member?(warehouse.walls, {r, c}) ->
                  "#"

                warehouse.robot == {r, c} ->
                  "@"

                true ->
                  "."
              end
          end) <> "\n"
      end)
      |> IO.puts()
    end

    defp get_stack(
           %Part2{walls: walls, boxes: boxes} = warehouse,
           {:ok, {r, c}},
           dir
         ) do
      cond do
        MapSet.member?(walls, {r, c}) ->
          {:halt, nil}

        Map.has_key?(boxes, {r, c}) ->
          {b_r, b_c} = Map.get(boxes, {r, c})
          {r_ofs, c_ofs} = get_next(dir)
          # IO.puts("Box edges = (#{r}, #{c}) and (#{b_r}, #{b_c})")
          res = MapSet.new([{r, c}, {b_r, b_c}])

          case dir do
            x when (x == :left and b_c < c) or (x == :right and b_c > c) ->
              # IO.puts("1st clause")
              {status, next} =
                get_stack(warehouse, {:ok, {b_r + r_ofs, b_c + c_ofs}}, dir)

              case status do
                :ok -> {:ok, res |> MapSet.union(next)}
                :halt -> {:halt, nil}
              end

            x when (x == :left and c < b_c) or (x == :right and c > b_c) ->
              # IO.puts("2nd clause going to (#{r+r_ofs},#{c+c_ofs})")
              {status, next} = get_stack(warehouse, {:ok, {r + r_ofs, c + c_ofs}}, dir)

              case status do
                :ok -> {:ok, res |> MapSet.union(next)}
                :halt -> {:halt, nil}
              end

            _ ->
              # IO.puts("3rd clause")
              # FIXME: Possible issue
              # IO.puts(
              #   "Making 2 recursive calls with: (#{r + r_ofs}, #{c + c_ofs}) and (#{b_r + r_ofs}, #{b_c + c_ofs})"
              # )

              {status_a, a_next} = get_stack(warehouse, {:ok, {r + r_ofs, c + c_ofs}}, dir)
              {status_b, b_next} = get_stack(warehouse, {:ok, {b_r + r_ofs, b_c + c_ofs}}, dir)

              case {status_a, status_b} do
                {:ok, :ok} ->
                  {:ok, res |> MapSet.union(a_next) |> MapSet.union(b_next)}

                {x, y} when x == :halt or y == :halt ->
                  {:halt, nil}
              end
          end

        true ->
          {:ok, MapSet.new()}
      end
    end

    defp get_boxes(%Part2{boxes: boxes}, stack) do
      Enum.reduce(stack, MapSet.new(), fn {_, a_c} = edge, acc ->
        {b_r, b_c} = Map.get(boxes, edge)

        if(b_c < a_c,
          do: {{b_r, b_c}, edge},
          else: {edge, {b_r, b_c}}
        )
        |> then(&MapSet.put(acc, &1))
      end)
    end

    def move_robot(
          %Part2{robot: robot_pos, walls: walls, boxes: boxes} = warehouse,
          move
        ) do
      direction =
        case move do
          "^" -> :up
          "v" -> :down
          "<" -> :left
          ">" -> :right
        end

      next_pos = get_next(robot_pos, direction)

      cond do
        MapSet.member?(walls, next_pos) ->
          warehouse

        Map.has_key?(boxes, next_pos) ->
          {status, stack} = get_stack(warehouse, {:ok, next_pos}, direction)

          case status do
            :halt ->
              warehouse

            :ok ->
              # IO.inspect(stack)

              boxes =
                stack
                |> then(&get_boxes(warehouse, &1))

              IO.puts("Have to move following boxes:")
              IO.inspect(boxes)

              new_warehouse =
                boxes
                |> Enum.reduce(warehouse, &move_double_box(&2, &1, direction))

              # IO.inspect(new_warehouse.boxes)

              %Part2{
                new_warehouse
                | robot: next_pos
              }
          end

        true ->
          %Part2{
            warehouse
            | robot: next_pos
          }
      end
    end

    def run([grid, moves]) do
      {max_rows, warehouse} =
        Enum.reduce(grid, {0, %Part2{}}, fn row, {r, acc} ->
          {_, acc} =
            row
            |> String.graphemes()
            |> Enum.reduce({0, acc}, fn elem, {c, wh} ->
              {c + 1, add_elem(wh, elem, {r, c * 2})}
            end)

          {r + 1, acc}
        end)

      moves =
        Enum.join(moves, "")
        |> String.graphemes()
        |> Enum.with_index()

      display(warehouse, max_rows)

      Enum.reduce(moves, warehouse, fn {m, idx}, acc ->
        IO.puts("Move #{idx}: #{m}")
        acc = move_robot(acc, m)
        # IO.puts("Boxes:")
        # IO.inspect(acc.boxes)
        # IO.puts("--------")
        display(acc, max_rows)
        acc
      end)

      # warehouse
      {:ok}
    end
  end

  defmodule Part1 do
    def run([grid, moves]) do
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
               Map.update(map, key, MapSet.new([{r, c}]), fn exist ->
                 MapSet.put(exist, {r, c})
               end)}
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

    defp get_stack(warehouse, {r, c}, dir) do
      boxes = Map.get(warehouse, :box)
      max_stack = 1000

      {r_incr, c_incr} = get_next(dir)

      Enum.map(0..max_stack, &{&1 * r_incr + r, &1 * c_incr + c})
      |> Enum.take_while(&MapSet.member?(boxes, &1))
    end

    defp move_robot(warehouse, move) do
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

  def main(filename) do
    input =
      filename
      |> File.stream!()
      |> Enum.map(&String.trim/1)
      |> Enum.chunk_by(&(&1 == ""))
      |> List.delete_at(1)

    {Part1.run(input), Part2.run(input)}
  end
end
