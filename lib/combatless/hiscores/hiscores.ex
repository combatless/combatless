defmodule Combatless.Hiscores do
  @moduledoc """
  The Hiscores context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo
  alias Combatless.Datapoints
  alias Combatless.Datapoints.SkillDatapoint
  alias Combatless.Accounts
  alias Combatless.Accounts.Account
  alias Ecto.Multi

  alias Combatless.Hiscores.Hiscore

  def account_preload(%Account{hiscores: hiscores} = account) when is_list(hiscores), do: account
  def account_preload(%Account{} = account) do
    Map.put(account, :hiscores, get_hiscores(account))
  end

  def get_hiscores(%Account{} = account) do
    datapoint = Accounts.get_latest_account_datapoint(account)

    Enum.map(datapoint.skill_datapoints, &skill_datapoint_to_hiscore(datapoint, &1))
  end

  defp skill_datapoint_to_hiscore(datapoint, skill_datapoint) do
    %Hiscore{
      account: datapoint.account,
      datapoint: datapoint,
      data: skill_datapoint,
      skill: skill_datapoint.skill
    }
  end

  def active_hiscores_query(skill) do
    real_skill = if skill == "ehp", do: "overall", else: skill

    from(
      d in subquery(Datapoints.get_unique_account_datapoints()),
      join: sd in assoc(d, :skill_datapoints),
      join: s in assoc(sd, :skill),
      join: a in assoc(d, :account),
      join: current_top in subquery(current_top_query(skill)),
      on: current_top.account_id == d.account_id,
      where: s.slug == ^real_skill and a.is_combatless == true and sd.rank > 0,# and a.id == current_top.account_id,
      select: %Hiscore{
        account: a,
        current: current_top.value,
        datapoint: d,
        data: sd,
        skill: s
      }
    )
    |> skill_order(skill)
  end

  def skill_order(query, "ehp"),
      do: from [h, sd] in query, order_by: [
        desc: sd.ehp
      ]
  def skill_order(query, "overall"),
      do: from [h, sd] in query, order_by: [
        desc: sd.virtual_level
      ]
  def skill_order(query, _),
      do: from [h, sd] in query, order_by: [
        asc: sd.rank
      ]

  def get_rank(%Account{} = account, skill) do
    real_skill = if skill == "ehp", do: "overall", else: skill
    skill_datapoint =
      account
      |> account_preload()
      |> Map.get(:hiscores)
      |> Enum.find(& &1.skill.slug == real_skill)
      |> Map.get(:data)

    skill
    |> active_hiscores_query()
    |> skill_rank(skill, skill_datapoint)
    |> Repo.aggregate(:count, :id)
    |> Kernel.+(1)
  end

  def skill_rank(query, "ehp", user_sd), do: from [h, sd] in query, where: sd.ehp > ^user_sd.ehp
  def skill_rank(query, "overall", user_sd), do: from [h, sd] in query, where: sd.virtual_level > ^user_sd.virtual_level
  def skill_rank(query, _, user_sd), do: from [h, sd] in query, where: sd.rank < ^user_sd.rank


  def get_ranks(%Account{} = account) do
    account = account_preload(account)

    account
    |> Map.get(:hiscores)
    |> Enum.reduce(
         %{},
         fn hiscore, acc ->
           skill = hiscore.skill.slug
           rank = if hiscore.data.rank > 0, do: get_rank(account, skill), else: -1
           acc = if skill == "overall", do: Map.put(acc, :ehp, get_rank(account, "ehp")), else: acc
           Map.put(acc, String.to_atom(skill), rank)
         end
       )
  end

  def get_unique_skill_datapoints(skill) do
    from(
      sd in Datapoints.get_unique_skill_datapoints(),
      join: s in assoc(sd, :skill),
      join: d in assoc(sd, :datapoint),
      join: a in assoc(d, :account),
      where: s.slug == ^skill and a.is_combatless == true and sd.rank > 0,
    )
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
      on: old_sd.account_id == d.account_id,
      distinct: d.account_id,
      where: s.slug == ^real_skill and d.fetched_at > ^starting_time,
      order_by: [
        desc: d.fetched_at
      ],
      select: %{
        account_id: d.account_id
      }
    )
    |> select_skill_value_fragment(skill)
  end

  defp select_skill_value_fragment(query, "ehp") do
    from [sd, old_sd] in query,
         select_merge: %{
           value: fragment("? - ?", sd.ehp, old_sd.value)
         }
  end

  defp select_skill_value_fragment(query, "overall") do
    from [sd, old_sd] in query,
         select_merge: %{
           value: fragment("? - ?", sd.virtual_level, old_sd.value)
         }
  end

  defp select_skill_value_fragment(query, skill) do
    from [sd, old_sd] in query,
         select_merge: %{
           value: fragment("? - ?", sd.xp, old_sd.value)
         }
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

  def oldest_skill_datapoint(account_id, skill, starting_time) do
    from(
      sd in SkillDatapoint,
      join: s in assoc(sd, :skill),
      join: d in assoc(sd, :datapoint),
      where: d.account_id == ^account_id and s.slug == ^skill and d.fetched_at > ^starting_time,
      order_by: [
        asc: d.fetched_at
      ],
      limit: 1,
      select: sd
    )
  end

  defp select_skill_value(query, "ehp"), do: from sd in query, select_merge: %{value: sd.ehp}
  defp select_skill_value(query, "overall"), do: from sd in query, select_merge: %{value: sd.virtual_level}
  defp select_skill_value(query, skill), do: from sd in query, select_merge: %{value: sd.xp}

  def get_current_week(account, skill) do
    real_skill = if skill == "ehp", do: "overall", else: skill
    skill_type = skill_type(skill)
    now = Timex.now()
    starting_time = Timex.shift(now, days: -7)
    from(
      sd in SkillDatapoint,
      join: sd2 in subquery(oldest_skill_datapoint(account.id, real_skill, starting_time)),
      join: s in assoc(sd, :skill),
      join: d in assoc(sd, :datapoint),
      where: d.account_id == ^account.id and s.slug == ^real_skill,
      order_by: [
        desc: d.fetched_at
      ],
      limit: 1,
      select: fragment("? - ?", sd.ehp, sd2.ehp)
    )
    |> Repo.one()
  end

  def skill_type(:ehp), do: :ehp
  def skill_type(skill), do: :xp
end
