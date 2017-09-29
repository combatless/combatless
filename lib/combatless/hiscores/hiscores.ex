defmodule Combatless.Hiscores do
  @moduledoc """
  The Hiscores context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo
  alias Combatless.Datapoints
  alias Combatless.Datapoints.SkillDatapoint
  alias Combatless.Accounts
  alias Combatless.Datapoints.Datapoint
  alias Combatless.Accounts.Account
  alias Ecto.Multi
  alias Combatless.CurrentTops

  alias Combatless.Hiscores.Hiscore

  def get_rank(account_id, skill, skill_datapoint) do
    real_skill = if skill == "ehp", do: "overall", else: skill

    skill
    |> active_hiscores_query()
    |> rank_order(skill, skill_datapoint)
    |> Repo.aggregate(:count, :account_id)
    |> Kernel.+(1)
  end

  def rank_order(query, "ehp", sd) do
    from hiscores in subquery(query), where: hiscores.value > ^sd.ehp
  end

  def rank_order(query, _, sd) do
    from hiscores in subquery(query), where: hiscores.value > ^sd.xp
  end

  def get_ranks(%Account{} = account) do
    datapoint = Accounts.get_latest_account_datapoint(account)

    Enum.reduce(datapoint.skill_datapoints, %{}, fn sd, acc ->
      skill = sd.skill.slug
      rank = if sd.rank > 0, do: get_rank(account, skill, sd), else: -1
      acc = if skill == "overall", do: Map.put(acc, :ehp, get_rank(account.id, "ehp", sd)), else: acc
      Map.put(acc, String.to_atom(skill), rank)
    end)
  end

  def hiscore_page_query(skill) do
    from(
      a in Accounts.active_accounts_query(),
      join: hiscore in subquery(active_hiscores_query(skill)),
      join: current_top in subquery(CurrentTops.current_top_query(skill)),
      on: hiscore.account_id == a.id and current_top.account_id == a.id,
      order_by: [
        desc: hiscore.value
      ],
      select: %Hiscore{
        account: a,
        current: current_top.value,
        value: hiscore.value
      }
    )
  end

  def active_hiscores_query(skill) do
    real_skill = if skill == "ehp", do: "overall", else: skill

    from(
      d in Datapoint,
      join: sd in assoc(d, :skill_datapoints),
      join: s in assoc(sd, :skill),
      group_by: d.account_id,
      where: s.slug == ^real_skill and d.is_valid == true,
      select: %{
        account_id: d.account_id
      }
    )
    |> select_hiscore_value(skill)
  end

  defp select_hiscore_value(query, "ehp") do
    from [d, sd] in query,
         select_merge: %{
           value: max(sd.ehp)
         }
  end

  defp select_hiscore_value(query, skill) do
    from [d, sd] in query,
         select_merge: %{
           value: max(sd.xp)
         }
  end
end
