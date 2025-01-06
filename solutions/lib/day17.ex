defmodule Day17 do
  defstruct a: 0, b: 0, c: 0, instruction_ptr: 0, output: [], program: []

  defp instructions(), do: [:adv, :bxl, :bst, :jnz, :bxc, :out, :bdv, :cdv]

  defp get_combo(_, x) when x <= 3, do: x
  defp get_combo(%Day17{a: a}, 4), do: a
  defp get_combo(%Day17{b: b}, 5), do: b
  defp get_combo(%Day17{c: c}, 6), do: c

  def div_combo(state, a, combo_op) do
    get_combo(state, combo_op)
    |> then(&Integer.pow(2, &1))
    |> then(&div(a, &1))
  end

  def adv(%Day17{a: a} = state, combo_op) do
    {2,
     div_combo(state, a, combo_op)
     |> then(&%Day17{state | a: &1})}
  end

  def bxl(%Day17{b: b} = state, literal_op) do
    {2,
     Bitwise.bxor(b, literal_op)
     |> then(&%Day17{state | b: &1})}
  end

  def bst(state, combo_op) do
    {2,
     get_combo(state, combo_op)
     |> rem(8)
     |> then(&%Day17{state | b: &1})}
  end

  def jnz(%Day17{a: 0} = state, _), do: {2, state}

  def jnz(%Day17{a: _} = state, literal_op), do: {0, %Day17{state | instruction_ptr: literal_op}}

  def bxc(%Day17{b: b, c: c} = state, _), do: {2, %Day17{state | b: Bitwise.bxor(b, c)}}

  def out(%Day17{output: o} = state, combo_op) do
    {2,
     get_combo(state, combo_op)
     |> rem(8)
     |> then(
       &%Day17{
         state
         | output: o ++ [&1]
       }
     )}
  end

  def bdv(%Day17{a: a} = state, combo_op) do
    {2,
     div_combo(state, a, combo_op)
     |> then(&%Day17{state | b: &1})}
  end

  def cdv(%Day17{a: a} = state, combo_op) do
    {2,
     div_combo(state, a, combo_op)
     |> then(&%Day17{state | c: &1})}
  end

  def run(%Day17{instruction_ptr: ip, program: p, output: o}) when ip >= length(p),
    do: Enum.join(o, ",")

  def run(%Day17{instruction_ptr: ip, program: p} = state) do
    opcode = Enum.at(p, ip) |> then(&Enum.at(instructions(), &1))
    operand = Enum.at(p, ip + 1)
    {incr, state} = Kernel.apply(Day17, opcode, [state, operand])

    run(%Day17{
      state
      | instruction_ptr: state.instruction_ptr + incr
    })
  end

  def run_part2(program) do
    insts =
      Enum.chunk_every(program, 2)
      |> Enum.map(fn [a, b] -> [Enum.at(instructions(), a), b] end)

    program
    |> Enum.reverse()
    |> Enum.reduce([0], fn target, acc ->
      # IDEA: Shift lower 3 digits of previous candidates left and add an offset k
      # then determine if any of them produce the valid output and contain any of
      # the previous candidates
      for(k <- 0..7, cand <- acc, do: k + Bitwise.<<<(cand, 3))
      |> Enum.filter(&execute(insts, %{target: target, final_a: acc}, %Day17{a: &1}))
    end)
    |> List.first()
  end

  def execute(insts, %{target: exp_o, final_a: exp_a}, state) do
    %Day17{output: o, a: a} =
      Enum.reduce(insts, state, fn [opcode, operand], acc ->
        {_, acc} = Kernel.apply(Day17, opcode, [acc, operand])
        acc
      end)

    o == [exp_o] and Enum.member?(exp_a, a)
  end

  def main(_) do
    state = %Day17{a: 2024, program: [0, 3, 5, 4, 3, 0]}
    {run(state), run_part2(state.program)}
  end
end
