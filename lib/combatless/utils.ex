defmodule Combatless.Utils do
  @moduledoc false


  @spec format_integer(integer) :: string
  def format_integer(string) when is_bitstring(string), do: string
  def format_integer(integer) do
    integer
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> partition_integer([])
    |> to_string()
  end

  defp partition_integer([a, b, c, ?- | _tail], acc) do
    [?-, c, b, a | acc]
  end

  defp partition_integer([a, b, c, d | tail], acc) do
    partition_integer [d | tail], [?,, c, b, a | acc]
  end

  defp partition_integer(rest, acc) do
    Enum.reverse(rest) ++ acc
  end
end
