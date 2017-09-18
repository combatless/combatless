defmodule Combatless.OSRS do
  @moduledoc false

  # from calculate_xp_table
  @xp_table [0, 83, 174, 276, 388, 512, 650, 801, 969, 1154, 1358, 1584, 1833, 2107, 2411,
    2746, 3115, 3523, 3973, 4470, 5018, 5624, 6291, 7028, 7842, 8740, 9730, 10824,
    12031, 13363, 14833, 16456, 18247, 20224, 22406, 24815, 27473, 30408, 33648,
    37224, 41171, 45529, 50339, 55649, 61512, 67983, 75127, 83014, 91721, 101333,
    111945, 123660, 136594, 150872, 166636, 184040, 203254, 224466, 247886,
    273742, 302288, 333804, 368599, 407015, 449428, 496254, 547953, 605032,
    668051, 737627, 814445, 899257, 992895, 1096278, 1210421, 1336443, 1475581,
    1629200, 1798808, 1986068, 2192818, 2421087, 2673114, 2951373, 3258594,
    3597792, 3972294, 4385776, 4842295, 5346332, 5902831, 6517253, 7195629,
    7944614, 8771558, 9684577, 10692629, 11805606, 13034431, 14391160, 15889109,
    17542976, 19368992, 21385073, 23611006, 26068632, 28782069, 31777943,
    35085654, 38737661, 42769801, 47221641, 52136869, 57563718, 63555443,
    70170840, 77474828, 85539082, 94442737, 104273167, 115126838, 127110260,
    140341028, 154948977, 171077457, 188884740, 200000000]


  def combat_level(skills) do
    hitpoints = max(10, skills.hitpoints.level)
    base = 0.25 * (skills.defence.level + hitpoints + trunc(skills.prayer.level / 2))
    melee = 0.325 * (skills.attack.level + skills.strength.level)
    range = 0.325 * (trunc(skills.ranged.level / 2) + skills.ranged.level)
    mage = 0.325 * (trunc(skills.magic.level / 2) + skills.magic.level)
    combat_type =
      melee
      |> max(range)
      |> max(mage)

    trunc(base + combat_type)
  end

  def get_level(xp) do
    min 99, get_virtual_level(xp)
  end

  def get_virtual_level(xp) when xp < 0, do: 0
  def get_virtual_level(xp) when xp >= 200_000_000, do: 126
  def get_virtual_level(xp) when xp >= 0 do
    Enum.find_index(@xp_table, & &1 > xp)
  end

  defp calculate_xp_table do
    Enum.map_reduce(
      Enum.to_list(0..126),
      0,
      fn (x, acc) ->
        points = acc + level_diff x
        {
          points / 4
          |> trunc()
          |> min(200_000_000),
          points
        }
      end
    )
    |> elem(0)
  end

  defp level_diff(level) when level == 0, do: 0
  defp level_diff(level), do: trunc(level + 300 * :math.pow(2, level / 7))
end
