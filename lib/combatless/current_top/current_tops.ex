defmodule Combatless.CurrentTops do

  import Ecto.Query, warn: false
  import Combatless.Utils, only: [period_to_arbitrary_days: 1]
  alias Combatless.Accounts
  alias Combatless.Datapoints.Datapoint
  alias Combatless.Datapoints.SkillDatapoint
  alias Combatless.Datapoints.Skill

  def current_top(skill, period) do
    starting_time = Timex.shift(Timex.now(), period_to_arbitrary_days(period))

    from(
      a in Accounts.active_accounts_query(),
      join: current_top in subquery(current_top_query(skill, starting_time)),
      on: a.id == current_top.account_id,
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
      d in subquery(unique_min_and_max_datapoints(starting_time)),
      join: max in SkillDatapoint,
      join: min in SkillDatapoint,
      join: s in Skill,
      on: s.slug == ^real_skill and max.skill_id == s.id and min.skill_id == s.id,
      on: max.datapoint_id == d.max_id and min.datapoint_id == d.min_id,
      select: %{
        account_id: d.account_id
      }
    )
    |> select_skill_value_fragment(skill)
  end

  defp select_skill_value_fragment(query, "ehp") do
    from [d, max, min] in query,
         select_merge: %{
           value: fragment("? - ?", max.ehp, min.ehp)
         }
  end

  defp select_skill_value_fragment(query, skill) do
    from [d, max, min] in query,
         select_merge: %{
           value: fragment("? - ?", max.xp, min.xp)
         }
  end

  def unique_min_and_max_datapoints(starting_time) do
    from(
      d in Datapoint,
      group_by: d.account_id,
      where: d.fetched_at > ^starting_time and d.is_valid == true,
      select: %{
        account_id: d.account_id,
        max_id: max(d.id),
        min_id: min(d.id)
      }
    )
  end
end
