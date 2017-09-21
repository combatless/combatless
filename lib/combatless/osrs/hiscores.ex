defmodule Combatless.OSRS.Hiscores do
  alias Combatless.OSRS.Hiscores.Hiscore
  alias Combatless.OSRS
  alias Combatless.OSRS.EHP

  @skills [
    :overall,
    :attack,
    :defence,
    :strength,
    :hitpoints,
    :ranged,
    :prayer,
    :magic,
    :cooking,
    :woodcutting,
    :fletching,
    :fishing,
    :firemaking,
    :crafting,
    :smithing,
    :mining,
    :herblore,
    :agility,
    :thieving,
    :slayer,
    :farming,
    :runecraft,
    :hunter,
    :construction
  ]


  @url "http://services.runescape.com/m=hiscore_oldschool/index_lite.ws?player="


  def get_skills(), do: @skills

  def retrieve(name) do
    with {:ok, response} <- HTTPoison.get(@url <> name),
         {:ok, raw_body} <- get_body(response),
         do: new(raw_body)
  end

  defp get_body(response) do
    case response.status_code do
      200 -> {:ok, response.body}
      404 -> {:error, :username_does_not_exist}
      _ -> {:error, :unknown}
    end
  end

  def new(raw_body) do
    with {:ok, raw_hiscores} <- parse_hiscores_format(raw_body),
         hiscores <- parse_raw_hiscores(raw_hiscores),
         do: {:ok, format_overall(hiscores)}
  end

  defp parse_hiscores_format(body) do
    case String.split(body) do
      hiscores when length(hiscores) >= 24 -> {:ok, Enum.zip(@skills, hiscores)}
      h when is_list h -> {:error, :unknown_hiscores_format}
      _ -> {:error, :unknown}
    end
  end

  defp parse_raw_hiscores(raw_hiscores) do
    Enum.reduce(raw_hiscores, %Hiscore{}, &parse_raw_hiscore/2)
  end

  defp parse_raw_hiscore(raw_hiscore, %Hiscore{} = hiscore) do
    case parse_raw_hiscore_data(raw_hiscore) do
      {:hitpoints, data} ->
        data =
          data
          |> Map.put(:level, max(10, data.level))
          |> Map.put_new(:virtual_level, max(10, OSRS.get_virtual_level(data.xp)))

        Map.put(hiscore, :hitpoints, data)

      {name, data} ->
        data = Map.put_new(data, :virtual_level, OSRS.get_virtual_level(data.xp))
        Map.put(hiscore, name, data)
    end
  end

  defp parse_raw_hiscore_data(raw_hiscore) do
    name = elem(raw_hiscore, 0)
    values =
      raw_hiscore
      |> elem(1)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    data =
      [:rank, :level, :xp]
      |> Enum.zip(values)
      |> Map.new()

    data = Map.put(:xp, max(0, data.xp))

    {name, data}
  end

  defp format_overall(hiscores) do
    put_in(hiscores.overall.virtual_level, sum_overall(hiscores, :virtual_level))
  end

  defp sum_overall(hiscores, skill) do
    hiscores
    |> Map.from_struct()
    |> Map.delete(:overall)
    |> Map.values()
    |> Enum.reduce(0, &(&1[skill] + &2))
  end
end
