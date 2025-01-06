defmodule Day16 do
  import Utils.Grid

  defmodule Maze do
    alias Utils.PriorityQueue
    defstruct reindeer: {-1, -1}, walls: MapSet.new(), goal: {-1, -1}
    @rotation_penalty 1000

    def dijkstra(%Maze{reindeer: r} = maze) do
      pq = PriorityQueue.new() |> PriorityQueue.insert(0, {r, :right})
      scores = %{{r, :right} => 0}
      max_val = :math.pow(10, 100)
      dijkstra_helper(maze, {pq, scores, max_val})
    end

    defp dijkstra_helper(%Maze{walls: walls, goal: goal} = maze, {pq, scores, lowest}) do
      max_val = :math.pow(10, 100)

      case PriorityQueue.empty?(pq) do
        true ->
          {scores, lowest}

        false ->
          {{pos, dir}, pq} = PriorityQueue.pop(pq)

          acc =
            if pos == goal do
              lowest = min(lowest, Map.get(scores, {pos, dir}))
              {pq, scores, lowest}
            else
              get_neighbors({pos, dir}, walls, Map.get(scores, {pos, dir}))
              |> Enum.reduce({pq, scores, lowest}, fn {cost, coors, dir}, {p, s, _} ->
                tentative_score = Map.get(s, {coors, dir}, max_val)

                cond do
                  cost <= tentative_score ->
                    s = Map.put(s, {coors, dir}, cost)
                    p = PriorityQueue.update(p, cost, {coors, dir})
                    {p, s, lowest}

                  true ->
                    {p, s, lowest}
                end
              end)
            end

          dijkstra_helper(maze, acc)
      end
    end

    def get_neighbors({pos, d}, walls, current_cost) do
      neighbors = [
        {current_cost + @rotation_penalty, pos, rotate_left(d)},
        {current_cost + @rotation_penalty, pos, rotate_right(d)}
      ]

      next = get_next(pos, d)

      if !MapSet.member?(walls, next) do
        neighbors ++ [{current_cost + 1, next, d}]
      else
        neighbors
      end
    end

    def get_neighbors({pos, d}, walls, current_cost, :reverse) do
      neighbors = [
        {current_cost - @rotation_penalty, pos, rotate_left(d)},
        {current_cost - @rotation_penalty, pos, rotate_right(d)}
      ]

      next = get_next(pos, opposite(d))

      if !MapSet.member?(walls, next) do
        neighbors ++ [{current_cost - 1, next, d}]
      else
        neighbors
      end
    end

    def count_seats(%Maze{goal: goal} = maze, scores, min_cost) do
      queue =
        directions()
        |> Enum.map(fn d -> {min_cost, goal, d} end)

      get_all_shortest_paths_helper(maze, scores, MapSet.new() |> MapSet.put(goal), queue)
      |> Enum.count()
    end

    defp get_all_shortest_paths_helper(_, _, possible_seats, []), do: possible_seats

    defp get_all_shortest_paths_helper(
           %Maze{walls: w, reindeer: r} = maze,
           scores,
           possible_seats,
           [top | rest_queue]
         ) do
      {cost, pos, dir} = top

      new_seats = MapSet.put(possible_seats, pos)

      if pos == r do
        get_all_shortest_paths_helper(maze, scores, new_seats, rest_queue)
      else
        neighbors =
          get_neighbors({pos, dir}, w, cost, :reverse)
          |> Enum.filter(fn {cost, pos, dir} -> Map.get(scores, {pos, dir}) == cost end)

        # To ensure we don't get into a cycle
        new_scores =
          Enum.reduce(neighbors, scores, fn {_, pos, dir}, acc ->
            Map.put(acc, {pos, dir}, :math.pow(10, 100))
          end)

        new_queue = Enum.concat(rest_queue, neighbors)

        get_all_shortest_paths_helper(maze, new_scores, new_seats, new_queue)
      end
    end
  end

  def main(filename) do
    maze =
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
            "E" -> %Maze{acc | goal: {r, c}}
            _ -> acc
          end
        end)
      end)

    {scores, min_cost} = Maze.dijkstra(maze)
    {min_cost, Maze.count_seats(maze, scores, min_cost)}
  end
end
