defmodule Combatless.OSRS.EHP do
  @moduledoc false
  alias Combatless.OSRS.Hiscores.Hiscore


  @ehp_version 1

  @rates %{
    attack: 0,
    defence: 0,
    strength: 0,
    hitpoints: 0,
    ranged: 0,
    prayer: 0,
    magic: 0,
    cooking: [{0, 40_000}, {7_842, 130_000}, {37_224, 175_000}, {737_627, 490_000}],
    woodcutting: [
      {0, 7_000},
      {2_411, 15_000},
      {13_363, 35_000},
      {22_406, 58_000},
      {273_742, 72_000},
      {1_986_068, 90_000},
      {5_346_332, 104_000},
      {13_034_431, 120_000}
    ],
    fletching: 0,
    fishing: [
      {0, 14_000},
      {4_470, 28_000},
      {13_363, 37_000},
      {273_742, 46_000},
      {737_627, 58_000},
      {1_986_068, 74_000},
      {5_346_332, 82_000},
      {13_034_431, 88_000}
    ],
    firemaking: [
      {0, 45_000},
      {13_363, 132_750},
      {61_512, 199_125},
      {273_742, 298_687},
      {1_210_421, 448_105},
      {5_346_332, 516_250},
      {158_000_000, 0} # infernal axe bonus xp
    ],
    crafting: [
      {0, 57_000},
      {300_000, 170_000},
      {362_000, 285_000},
      {496_254, 336_875},
      {2_951_373, 425_000},
      {174_324_320, 0} # soul rc bonus xp
    ],
    smithing: [{0, 40_000}, {18_247, 116_000}, {605_032, 232_000}, {4_385_776, 290_000}],
    mining: [
      {0, 8_000},
      {14_833, 20_000},
      {41_171, 44_000},
      {302_288, 60_000},
      {1_210_421, 80_000},
      {5_346_332, 95_000},
      {13_034_431, 105_000},
      {180_743_240, 0} # soul rc bonus xp
    ],
    herblore: [{0, 60_000}, {27_473, 200_000}, {2_192_818, 425_000}],
    agility: [
      {0, 6_000},
      {13_363, 15_100},
      {75_127, 42_000},
      {273_742, 45_000},
      {737_627, 49_000},
      {1_986_086, 52_000},
      {3_972_294, 59_000},
      {9_684_577, 62_000}
    ],
    thieving: [
      {0, 15_000},
      {61_512, 55_000},
      {166_636, 90_000},
      {449_428, 215_000},
      {5_902_831, 250_000},
      {13_034_431, 260_000}
    ],
    slayer: 0,
    farming: [
      {0, 10_000},
      {2_411, 50_000},
      {13_363, 80_000},
      {61_512, 150_000},
      {273_742, 350_000},
      {1_210_421, 2_000_000}
    ],
    runecraft: [{0, 8_000}, {6_291, 40_000}, {5_346_332, 43_200}],
    hunter: [
      {0, 5_000},
      {12_031, 40_000},
      {247_886, 80_000},
      {992_895, 100_000},
      {1_986_068, 115_000},
      {5_346_332, 145_000},
      {13_034_431, 170_000}
    ],
    construction: [{0, 20_000}, {18_247, 100_000}, {123_660, 875_000}]
  }

  # fletch [{0, 30000}, {969, 45000}, {33648, 150000}, {50339, 250000}, {150872, 500000}, {302288, 700000}, {13034431, 850000}],

  def get_rates, do: @rates
  def get_version, do: @ehp_version

  @doc """
  Returns a tuple with the first element the ehp version and the second with the ehp
"""
  @spec calculate(%Hiscore{}) :: {integer, %Hiscore{}}
  def calculate(%Hiscore{} = hiscore) do
    with_ehp =
      hiscore
      |> Map.from_struct()
      |> Enum.reduce(hiscore, &calculate_skill/2)
      |> sum_overall_ehp()

    {@ehp_version, with_ehp}
  end

  defp calculate_skill({skill, data}, hiscore) do
    skill_hiscore = Map.put(data, :ehp, get_ehp_from_xp(data.xp, skill))
    Map.put(hiscore, skill, skill_hiscore)
  end

  defp sum_overall_ehp(%Hiscore{} = hiscore) do
    sum =
      hiscore
      |> Map.from_struct()
      |> Map.delete(:overall)
      |> Map.values()
      |> Enum.reduce(0, & &1.ehp + &2)
      |> Float.round(3)

    hiscore
    |> Map.get_and_update(:overall, & {&1, %{&1 | ehp: sum}})
    |> elem(1)
  end

  def get_ehp_from_xp(xp, skill) do
    case Map.get(@rates, skill) do
      0 -> 0.0
      nil -> 0.0
      rates when is_list(rates) -> get_ehp(rates, xp)
    end
  end

  defp get_ehp(rates, xp) do
    rates
    |> Enum.reverse()
    |> Enum.reduce({xp, 0.0}, &add_up/2)
    |> elem(1)
    |> Float.round(3)
  end

  defp add_up({step, 0}, {xp, ehp}), do: {min(step, xp), ehp}
  defp add_up({step, hourly}, {xp, ehp}) do
    if xp > step do
      {step, ehp + ((xp - step) / hourly)}
    else
      {xp, ehp}
    end
  end
end
