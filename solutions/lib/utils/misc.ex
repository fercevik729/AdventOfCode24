defmodule Utils.Misc do
  @doc ~S"""
  Concatenates the digits of two numbers

    ## Examples

      iex> Utils.Misc.concat_digits(12, 345)
      12345

      iex> Utils.Misc.concat_digits(41, 27)
      4127
  """
  def concat_digits(fst, snd) do
    (Integer.to_string(fst) <> Integer.to_string(snd))
    |> String.to_integer()
  end

  def repeat_n(_, 0), do: []

  @doc ~S"""
  Creates an enumerable by repeating `item`, `n` times

    ## Examples

      iex> Utils.Misc.repeat_n(4, 0)
      []

      iex> Utils.Misc.repeat_n(:hello, 4)
      [:hello, :hello, :hello, :hello]
  """
  def repeat_n(item, times) do
    Enum.map(1..times, fn _ -> item end)
  end
end
