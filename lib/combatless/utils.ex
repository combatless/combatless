defmodule Combatless.Utils do
  @moduledoc false
  alias Number.Delimit

  def delimit(string) when is_bitstring(string), do: string
  def delimit(number) when is_integer(number), do:  Delimit.number_to_delimited(number, precision: 0)
  def delimit(number) when number == 0, do: Delimit.number_to_delimited(number, precision: 0)
  def delimit(number) when is_float(number), do: Delimit.number_to_delimited(number, precision: 2)

  def period_to_arbitrary_days(:day), do: [days: -1]
  def period_to_arbitrary_days(:week), do: [days: -7]
  def period_to_arbitrary_days(:month), do: [days: -31]
  def period_to_arbitrary_days(:year), do: [days: -365]
end
