defmodule Combatless.CurrentTops do

  import Ecto.Query, warn: false
  alias Combatless.Utils
  alias Combatless.Datapoints.Datapoint
  alias Combatless.Datapoints.SkillDatapoint

  def current_top(skill, period) do
    starting_time = Timex.shift(Timex.now(), Utils.period_to_arbitrary_days(period))

    from(
      current_top in subquery(current_top_query(skill, starting_time)),
      join: d in Datapoint,
      join: a in assoc(d, :account),
      on: d.id == current_top.datapoint_id,
      where: current_top.value > 0,
      order_by: [
        desc: current_top.value
      ],
      select: %{
        account: a,
        value: current_top.value
      }
    )
  end

  def current_top_subquery(skill), do: current_top_subquery(skill, Timex.shift(Timex.now(), days: -7))
  def current_top_subquery(skill, starting_time) do
    skill
    |> current_top_query(starting_time)
    |> exclude(:select)
    |> select([sd, ..., a], %{account_id: a.id})
    |> select_skill_value_fragment(skill)
  end

  def current_top_query(skill), do: current_top_query(skill, Timex.shift(Timex.now(), days: -7))
  def current_top_query(skill, starting_time) do
    real_skill = if skill == "ehp", do: "overall", else: skill
    skill_type = skill_type(skill)
    from(
      sd in SkillDatapoint,
      join: old_sd in subquery(least_recent_skill_datapoints_query(skill, starting_time)),
      join: s in assoc(sd, :skill),
      join: d in assoc(sd, :datapoint),
      join: a in assoc(d, :account),
      on: old_sd.account_id == d.account_id,
      distinct: d.account_id,
      where: s.slug == ^real_skill and d.fetched_at > ^starting_time,
      select: %{
        datapoint_id: d.id
      }
    )
    |> select_skill_value_fragment(skill)
  end

  def least_recent_skill_datapoints_query(skill, starting_time) do
    real_skill = if skill == "ehp", do: "overall", else: skill
    from(
      sd in SkillDatapoint,
      join: s in assoc(sd, :skill),
      join: d in assoc(sd, :datapoint),
      distinct: d.account_id,
      where: s.slug == ^real_skill and d.fetched_at > ^starting_time and sd.rank > 0,
      order_by: [
        asc: d.fetched_at
      ],
      select: %{
        account_id: d.account_id,
      }
    )
    |> select_skill_value(skill)
  end


  defp select_skill_value_fragment(query, "ehp") do
    from [sd, old_sd] in query,
         select_merge: %{
           value: fragment("? - ?", sd.ehp, old_sd.value)
         }
  end

  defp select_skill_value_fragment(query, skill) do
    from [sd, old_sd] in query,
         select_merge: %{
           value: fragment("? - ?", sd.xp, old_sd.value)
         }
  end

  defp select_skill_value(query, "ehp"),
       do: from sd in query,
           select_merge: %{
             value: sd.ehp
           }
  defp select_skill_value(query, skill),
       do: from sd in query,
           select_merge: %{
             value: sd.xp
           }

  def skill_type(:ehp), do: :ehp
  def skill_type(skill), do: :xp
end
