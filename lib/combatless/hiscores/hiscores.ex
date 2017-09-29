defmodule Combatless.Hiscores do
  @moduledoc """
  The Hiscores context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo
  alias Combatless.CurrentTops
  alias Combatless.Accounts.Account
  alias Combatless.Hiscores.Hiscore
  alias Combatless.Datapoints.Datapoint
  alias Combatless.Datapoints.SkillDatapoint


  def upsert_hiscore(attrs \\ %{}) do
    %Hiscore{}
    |> Hiscore.changeset(attrs)
    |> Repo.insert(conflict_target: [:account_id, :skill_id], on_conflict: :replace_all)
  end

  def preload_hiscores(%Account{} = account) do
    Repo.preload(account, [hiscores: [:skill]])
  end

  @spec generate_hiscores(%Datapoint{} | {atom, any}) :: {:ok | :error, any}
  def generate_hiscores({:error, error}), do: {:error, error}
  def generate_hiscores({:ok, %Datapoint{} = datapoint}), do: generate_hiscores(datapoint)
  def generate_hiscores(%Datapoint{} = datapoint) do
    Repo.transaction(fn -> do_generate_hiscores(datapoint) end)
  end

  defp do_generate_hiscores(%Datapoint{} = datapoint) do
    Enum.each(
      datapoint.skill_datapoints,
      fn skill_datapoint ->
        upsert_hiscore(
          %{
            account_id: datapoint.account_id,
            skill_id: skill_datapoint.skill_id,
            value: get_hiscore_value(skill_datapoint)
          }
        )
      end
    )
  end

  def get_hiscore_value(%SkillDatapoint{skill_id: 1} = skill_datapoint), do: skill_datapoint.ehp
  def get_hiscore_value(%SkillDatapoint{} = skill_datapoint), do: skill_datapoint.xp

  def get_ranks(%Account{} = account) do
    account
    |> preload_hiscores()
    |> Map.get(:hiscores)
    |> Enum.reduce(%{}, fn hiscore, acc ->
      skill = hiscore.skill.slug
      Map.put(acc, String.to_atom(skill), get_rank(hiscore.value, skill))
    end)
    |> IO.inspect()
  end

  def get_rank(value, skill) do
    skill
    |> active_hiscores_query()
    |> where([h], h.value > ^value)
    |> Repo.aggregate(:count, :id)
    |> Kernel.+(1)
  end

  def hiscore_page_query(skill) do
    from(
      h in active_hiscores_query(skill),
      join: a in assoc(h, :account),
      join: current_top in subquery(CurrentTops.current_top_query(skill)),
      on: h.account_id == current_top.account_id,
      preload: [:account],
      order_by: [
        desc: h.value
      ],
      select_merge: %{
        current: current_top.value
      }
    )
  end

  def active_hiscores_query(skill) do
    real_skill = if skill == "ehp", do: "overall", else: skill

    from(
      h in Hiscore,
      join: s in assoc(h, :skill),
      join: a in assoc(h, :account),
      where: s.slug == ^real_skill and a.is_combatless == true and a.is_on_hiscores == true,
    )
  end



end
