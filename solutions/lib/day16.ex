defmodule Day16 do
  import Utils.Grid

  defmodule Maze do
    alias Utils.PriorityQueue
    defstruct reindeer: {-1, -1}, direction: :right, walls: MapSet.new(), end: {-1, -1}
    @rotation_penalty 1000

    def heuristic({r_r, r_c}, {e_r, e_c}),
      do: abs(r_r - e_r) + abs(r_c - e_c)

    def a_star_search(%Maze{reindeer: r, end: goal, direction: d} = maze) do
      pq = PriorityQueue.new() |> PriorityQueue.insert(0, {r, d})
      fScore = %{r => heuristic(r, goal)}
      gScore = %{r => 0}
      max_val = :math.pow(10, 100)
      cameFrom = %{}
      iter = Stream.iterate(0, &(&1 + 1))

      Enum.reduce_while(iter, {pq, fScore, gScore, cameFrom}, fn _,
                                                                 {pq, fScore, gScore, cameFrom} ->
        case PriorityQueue.empty?(pq) do
          true ->
            {:halt, max_val}

          false ->
            {{pos, dir}, pq} = PriorityQueue.pop(pq)

            if pos == goal do
              {:halt, Map.get(fScore, pos)}
            else
              new_maze = %Maze{maze | reindeer: pos, direction: dir}

              new_acc =
                get_neighbors(new_maze, Map.get(gScore, pos))
                |> Enum.reduce({pq, fScore, gScore, cameFrom}, fn {g, coors, dir},
                                                                  {p, fs, gs, cm} = acc ->
                  current_gs = Map.get(gs, coors, max_val)

                  cond do
                    g <= current_gs ->
                      gs = Map.put(gs, coors, g)
                      fs = Map.put(fs, coors, g + heuristic(coors, goal))
                      cm = Map.put(cm, coors, [pos])
                      p = PriorityQueue.update(p, Map.get(fs, coors), {coors, dir})
                      {p, fs, gs, cm}

                    true ->
                      acc
                  end
                end)

              {:cont, new_acc}
            end
        end
      end)
    end

    def get_neighbors(%Maze{reindeer: r, walls: w, direction: d}, current_cost) do
      dirs = directions()

      dirs
      |> Enum.map(fn dir -> {dir, get_next(r, dir)} end)
      |> Enum.filter(fn {_, pos} -> !MapSet.member?(w, pos) end)
      |> Enum.map(fn {dir, pos} ->
        # { g(n), neighbor, dir }
        {current_cost + rotations(d, dir) * @rotation_penalty + 1, pos, dir}
      end)
    end
  end

  def part1(filename) do
    filename
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce(%Maze{}, fn {row, r}, maze ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(maze, fn {char, c}, %Maze{walls: walls} = acc ->
        case char do
          "#" -> %Maze{acc | walls: MapSet.put(walls, {r, c})}
          "S" -> %Maze{acc | reindeer: {r, c}}
          "E" -> %Maze{acc | end: {r, c}}
          _ -> acc
        end
      end)
    end)
    |> Maze.a_star_search()
    |> IO.inspect(limit: :infinity)
  end
end
