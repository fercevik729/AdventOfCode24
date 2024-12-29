defmodule Utils.Math do
  @doc ~S"""

  ## Parameters
    number - any integer/float
    divisor - what to divide by

  ## Returns
    {quotient, remainder}

  ## Examples
      iex> Utils.Math.divmod(12, 2)
      {6, 0}

      iex> Utils.Math.divmod(14, 5)
      {2, 4}
  """
  def divmod(number, divisor) do
    result = number / divisor
    quotient = floor(result)
    remainder = number - quotient * divisor
    {quotient, remainder}
  end
end
