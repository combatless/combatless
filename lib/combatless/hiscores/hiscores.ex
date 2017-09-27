defmodule Combatless.Hiscores do
  @moduledoc """
  The Hiscores context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo
  alias Combatless.Datapoints
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

    Enum.map(datapoint.skill_datapoints, & skill_datapoint_to_hiscore(datapoint, &1))
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
      where: s.slug == ^real_skill and a.is_combatless == true and sd.rank > 0,
      select: %Hiscore{
        account: a,
        datapoint: d,
        data: sd,
        skill: s
      }
    )
    |> skill_order(skill)
  end

  def skill_order(query, "ehp"), do: from [h, sd] in query, order_by: [desc: sd.ehp]
  def skill_order(query, "overall"), do: from [h, sd] in query, order_by: [desc: sd.virtual_level]
  def skill_order(query, _), do: from [h, sd] in query, order_by: [asc: sd.rank]

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
    |> Enum.reduce(%{}, fn hiscore, acc ->
      skill = hiscore.skill.slug
      rank = if hiscore.data.rank > 0, do: get_rank(account, skill), else: -1
      acc = if skill == "overall", do: Map.put(acc, :ehp, get_rank(account, "ehp")), else: acc
      Map.put(acc, String.to_atom(skill), rank)
    end)
  end
end
