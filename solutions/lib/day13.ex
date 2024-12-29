defmodule Day13 do
  import Utils.Math
  @button_regex ~r/Button \S: X\+(\d+), Y\+(\d+)/
  @prize_regex ~r/Prize: X=(\d+), Y=(\d+)/
  def main(filename) do
    part2_offset = 10_000_000_000_000

    File.read!(filename)
    |> String.split("\n")
    |> Enum.chunk_every(4)
    |> Enum.map(&parse/1)
    |> Enum.reduce({0, 0}, fn args, {acc1, acc2} ->
      {acc1 + solve(args, 0), acc2 + solve(args, part2_offset)}
    end)
  end

  defp parse([b1, b2, prize, _]), do: parse([b1, b2, prize])

  defp parse([b1, b2, prize]) do
    [[_, b1x, b1y]] = Regex.scan(@button_regex, b1)
    [[_, b2x, b2y]] = Regex.scan(@button_regex, b2)
    [[_, px, py]] = Regex.scan(@prize_regex, prize)
    f = &String.to_integer/1
    [{f.(b1x), f.(b1y)}, {f.(b2x), f.(b2y)}, {f.(px), f.(py)}]
  end

  def solve([b1, b2, prize], prize_offset) do
    {px, py} = prize
    px = px + prize_offset
    py = py + prize_offset

    {alpha, gamma} = b1
    {beta, delta} = b2

    # Solve 2 homogenous equations for 2 variables a and b
    with {b, 0} <- divmod(alpha * py - gamma * px, alpha * delta - gamma * beta),
         {a, 0} <- divmod(px - beta * b, alpha) do
      3 * a + b
    else
      _ -> 0
    end
  end
end
