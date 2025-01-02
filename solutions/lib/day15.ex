defmodule Day15 do
  import Utils.Grid

  defmodule Part2 do
    defstruct boxes: [], robot: {0, 0}, walls: MapSet.new()

    def find_box(%Part2{boxes: boxes}, edge) do
      boxes
      |> Enum.find(fn {l, r} -> l == edge or r == edge end)
    end

    def box_exists?(warehouse, edge) do
      find_box(warehouse, edge) != nil
    end

    defp update_box(%Part2{boxes: boxes} = warehouse, old, new) do
      %Part2{
        warehouse
        | boxes:
            Enum.reduce(boxes, [], fn b, acc ->
              acc ++
                [
                  case b do
                    ^old -> new
                    _ -> b
                  end
                ]
            end)
      }
    end

    defp add_elem(%Part2{boxes: boxes} = warehouse, elem, {r, c}) do
      case elem do
        "#" ->
          %Part2{
            warehouse
            | walls: MapSet.put(warehouse.walls, {r, c}) |> MapSet.put({r, c + 1})
          }

        "O" ->
          %Part2{
            warehouse
            | boxes: boxes ++ [{{r, c}, {r, c + 1}}]
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
                box_exists?(warehouse, {r, c}) ->
                  {prev, _} = find_box(warehouse, {r, c})

                  if prev == {r, c} do
                    "["
                  else
                    "]"
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

        box_exists?(warehouse, {r, c}) ->
          {{r, c}, {b_r, b_c}} = find_box(warehouse, {r, c})
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

        box_exists?(warehouse, next_pos) ->
          {status, stack} = get_stack(warehouse, {:ok, next_pos}, direction)

          case status do
            :halt ->
              warehouse

            :ok ->
              # IO.inspect(stack)

              start_boxes =
                Enum.reduce(stack, MapSet.new(), fn b, acc ->
                  MapSet.put(acc, find_box(warehouse, b))
                end)

              {r_ofs, c_ofs} = get_next(direction)

              new_boxes =
                Enum.reduce(start_boxes, MapSet.new(), fn {{a_r, a_c}, {b_r, b_c}}, acc ->
                  MapSet.put(acc, {{a_r + r_ofs, a_c + c_ofs}, {b_r + r_ofs, b_c + c_ofs}})
                end)

              # IO.puts("Have to move following boxes:")
              # IO.inspect(start_boxes)

              to_remove = MapSet.difference(start_boxes, new_boxes)
              to_add = MapSet.difference(new_boxes, start_boxes)

              boxes =
                Enum.reduce(boxes, [], fn b, acc ->
                  if MapSet.member?(to_remove, b) do
                    acc
                  else
                    acc ++ [b]
                  end
                end)
                |> Enum.concat(to_add)

              %Part2{
                warehouse
                | robot: next_pos,
                  boxes: boxes
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

      # display(warehouse, max_rows)

      final =
        Enum.reduce(moves, warehouse, fn {m, idx}, acc ->
          # IO.puts("Move #{idx}: #{m}")
          acc = move_robot(acc, m)
          # IO.puts("Boxes:")
          # IO.inspect(acc.boxes)
          # IO.puts("--------")
          # display(acc, max_rows)
          acc
        end)

      display(final, max_rows)

      final.boxes
      |> Enum.reduce(0, fn {{a_r, a_c}, _}, acc ->
        acc + a_r * 100 + a_c
      end)
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
