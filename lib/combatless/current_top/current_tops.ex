defmodule Combatless.CurrentTops do

  import Ecto.Query, warn: false
  import Combatless.Utils, only: [period_to_arbitrary_days: 1]
  alias Combatless.Accounts.Account
  alias Combatless.Datapoints.Datapoint

  def current_top(skill, period) do
    starting_time = Timex.shift(Timex.now(), period_to_arbitrary_days(period))

    from(
      a in Account,
      join: current_top in subquery(current_top_query(skill, starting_time)),
      on: a.id == current_top.account_id,
      where: a.is_combatless == true,
      order_by: [
        desc: current_top.value
      ],
      select: %{
        account: a,
        value: current_top.value
      }
    )
  end

  def current_top_query(skill), do: current_top_query(skill, Timex.shift(Timex.now(), days: -7))
  def current_top_query(skill, starting_time) do
    real_skill = if skill == "ehp", do: "overall", else: skill
    from(
      d in Datapoint,
      join: sd in assoc(d, :skill_datapoints),
      join: s in assoc(sd, :skill),
      group_by: d.account_id,
      where: d.fetched_at > ^starting_time and s.slug == ^real_skill,
      select: %{
        account_id: d.account_id
      }
    )
    |> select_skill_value_fragment(skill)
  end

  defp select_skill_value_fragment(query, "ehp") do
    from [d, sd] in query,
         select_merge: %{
           value: fragment("? - ?", max(sd.ehp), min(sd.ehp))
         }
  end

  defp select_skill_value_fragment(query, skill) do
    from [d, sd] in query,
         select_merge: %{
           value: fragment("? - ?", max(sd.xp), min(sd.xp))
         }
  end
end
