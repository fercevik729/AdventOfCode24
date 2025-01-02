defmodule Day15 do
  import Utils.Grid

  defmodule Warehouse do
    defstruct boxes: MapSet.new(), robot: {0, 0}, walls: MapSet.new()

    def find_box(%Warehouse{boxes: boxes}, edge) do
      boxes
      |> Enum.find(fn {l, r} -> l == edge or r == edge end)
    end

    def box_exists?(warehouse, edge) do
      find_box(warehouse, edge) != nil
    end

    def add_elem(%Warehouse{boxes: boxes, walls: walls} = warehouse, elem, {r, c}, is_part2) do
      case elem do
        "#" ->
          %Warehouse{
            warehouse
            | walls:
                if is_part2 do
                  MapSet.put(walls, {r, c}) |> MapSet.put({r, c + 1})
                else
                  MapSet.put(walls, {r, c})
                end
          }

        "O" ->
          %Warehouse{
            warehouse
            | boxes:
                if is_part2 do
                  MapSet.put(boxes, {{r, c}, {r, c + 1}})
                else
                  MapSet.put(boxes, {r, c})
                end
          }

        "@" ->
          %Warehouse{
            warehouse
            | robot: {r, c}
          }

        "." ->
          warehouse
      end
    end

    def display(warehouse, max_rows, is_part2) do
      Enum.reduce(0..(max_rows - 1), "", fn r, output ->
        output <>
          Enum.reduce(0..(max_rows * 2 - 1), "", fn c, acc ->
            acc <>
              cond do
                is_part2 and box_exists?(warehouse, {r, c}) ->
                  {prev, _} = find_box(warehouse, {r, c})

                  if prev == {r, c} do
                    "["
                  else
                    "]"
                  end

                MapSet.member?(warehouse.boxes, {r, c}) ->
                  "O"

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

    # PART 1
    defp get_stack(%Warehouse{boxes: boxes, walls: walls} = warehouse, {:ok, curr}, dir, false) do
      case MapSet.member?(boxes, curr) do
        true ->
          next_box = get_next(curr, dir)
          {status, next} = get_stack(warehouse, {:ok, next_box}, dir, false)

          case status do
            :ok ->
              {:ok, MapSet.new([curr]) |> MapSet.union(next)}

            :halt ->
              {:halt, nil}
          end

        false ->
          if MapSet.member?(walls, curr) do
            {:halt, nil}
          else
            {:ok, MapSet.new()}
          end
      end
    end

    # PART 2
    defp get_stack(%Warehouse{walls: walls} = warehouse, {:ok, {r, c}}, dir, true) do
      cond do
        MapSet.member?(walls, {r, c}) ->
          {:halt, nil}

        box_exists?(warehouse, {r, c}) ->
          {{r, c} = a, {b_r, b_c} = b} = find_box(warehouse, {r, c})
          res = MapSet.new([{r, c}, {b_r, b_c}])

          case dir do
            x when (x == :left and b_c < c) or (x == :right and b_c > c) ->
              {status, next} =
                get_stack(warehouse, {:ok, get_next(b, dir)}, dir, true)

              case status do
                :ok -> {:ok, res |> MapSet.union(next)}
                :halt -> {:halt, nil}
              end

            x when (x == :left and c < b_c) or (x == :right and c > b_c) ->
              {status, next} = get_stack(warehouse, {:ok, get_next(a, dir)}, dir, true)

              case status do
                :ok -> {:ok, res |> MapSet.union(next)}
                :halt -> {:halt, nil}
              end

            _ ->
              {status_a, a_next} = get_stack(warehouse, {:ok, get_next(a, dir)}, dir, true)

              {status_b, b_next} =
                get_stack(warehouse, {:ok, get_next(b, dir)}, dir, true)

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

    defp move_robot(
           %Warehouse{robot: robot_pos, walls: walls, boxes: boxes} = warehouse,
           move,
           is_part2
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

        MapSet.member?(boxes, next_pos) or (is_part2 and box_exists?(warehouse, next_pos)) ->
          {status, stack} = get_stack(warehouse, {:ok, next_pos}, direction, is_part2)

          case status do
            :halt ->
              warehouse

            :ok ->
              start_boxes =
                Enum.reduce(stack, MapSet.new(), fn b, acc ->
                  if is_part2 do
                    MapSet.put(acc, find_box(warehouse, b))
                  else
                    MapSet.put(acc, b)
                  end
                end)

              new_boxes =
                case is_part2 do
                  true ->
                    Enum.reduce(start_boxes, MapSet.new(), fn {a, b}, acc ->
                      MapSet.put(acc, {get_next(a, direction), get_next(b, direction)})
                    end)

                  false ->
                    Enum.reduce(start_boxes, MapSet.new(), fn box, acc ->
                      MapSet.put(acc, get_next(box, direction))
                    end)
                end

              to_remove = MapSet.difference(start_boxes, new_boxes)
              to_add = MapSet.difference(new_boxes, start_boxes)
              boxes = MapSet.difference(boxes, to_remove) |> MapSet.union(to_add)

              %Warehouse{
                warehouse
                | robot: next_pos,
                  boxes: boxes
              }
          end

        true ->
          %Warehouse{
            warehouse
            | robot: next_pos
          }
      end
    end

    def run([grid, moves], is_part2) do
      {max_rows, warehouse} =
        Enum.reduce(grid, {0, %Warehouse{}}, fn row, {r, acc} ->
          {_, acc} =
            row
            |> String.graphemes()
            |> Enum.reduce({0, acc}, fn elem, {c, wh} ->
              if is_part2 do
                {c + 1, add_elem(wh, elem, {r, c * 2}, true)}
              else
                {c + 1, add_elem(wh, elem, {r, c}, false)}
              end
            end)

          {r + 1, acc}
        end)

      final =
        Enum.join(moves, "")
        |> String.graphemes()
        |> Enum.reduce(warehouse, &move_robot(&2, &1, is_part2))

      display(final, max_rows, is_part2)

      if is_part2 do
        Enum.reduce(final.boxes, 0, fn {{a_r, a_c}, _}, acc ->
          acc + a_r * 100 + a_c
        end)
      else
        Enum.reduce(final.boxes, 0, fn {r, c}, acc ->
          acc + r * 100 + c
        end)
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

    {Warehouse.run(input, false), Warehouse.run(input, true)}
  end
end
