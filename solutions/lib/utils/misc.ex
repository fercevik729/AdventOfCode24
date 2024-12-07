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
end
