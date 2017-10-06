defmodule Combatless.Hiscores do
  @moduledoc """
  The Hiscores context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo
  alias Combatless.CurrentTops
  alias Combatless.Accounts
  alias Combatless.Accounts.Account
  alias Combatless.Hiscores.Hiscore
  alias Combatless.Datapoints.Skill
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
    ehp = Repo.get_by(Skill, slug: "ehp")

    Enum.each(
      datapoint.skill_datapoints,
      fn skill_datapoint ->
        upsert_hiscore(
          %{
            account_id: datapoint.account_id,
            skill_id: skill_datapoint.skill_id,
            value: skill_datapoint.xp,
            alt_value: skill_datapoint.ehp,
            rank: skill_datapoint.rank
          }
        )

        if skill_datapoint.skill_id == 1 do
          upsert_hiscore(
            %{
              account_id: datapoint.account_id,
              skill_id: ehp.id,
              value: skill_datapoint.ehp,
              alt_value: skill_datapoint.xp,
              rank: skill_datapoint.rank
            }
          )
        end
      end
    )
  end

  def get_ranks(%Account{} = account) do
    account
    |> preload_hiscores()
    |> Map.get(:hiscores)
    |> Enum.reduce(%{}, fn hiscore, acc ->
      skill = hiscore.skill.slug
      Map.put(acc, String.to_atom(skill), get_rank(hiscore, skill))
    end)
  end

  def get_rank(hiscore, skill) do
    skill
    |> active_hiscores_query()
    |> sort_by_skill(hiscore, skill)
    |> Repo.aggregate(:count, :id)
    |> Kernel.+(1)
  end

  def sort_by_skill(query, hiscore, "ehp"), do: where(query, [h], h.value > ^hiscore.value)
  def sort_by_skill(query, hiscore, _), do: where(query, [h], h.value >= ^hiscore.value and h.rank < ^hiscore.rank)

  def hiscore_page_query(skill) do
    from(
      h in active_hiscores_query(skill),
      join: a in assoc(h, :account),
      left_join: current_top in subquery(CurrentTops.current_top_query(skill)),
      on: h.account_id == current_top.account_id,
      preload: [:account],
      select_merge: %{
        current: fragment("coalesce(?, ?)", current_top.value, 0)
      }
    )
    |> order_by_skill(skill)
  end

  def order_by_skill(query, _), do: order_by(query, [h], [desc: h.value, asc: h.rank])

  def active_hiscores_query(skill) do
    from(
      h in Hiscore,
      join: s in assoc(h, :skill),
      join: a in assoc(h, :account),
      where: s.slug == ^skill and a.is_combatless == true and a.is_on_hiscores == true,
    )
  end

  def rebuild_hiscores() do
    Repo.delete_all(Hiscore)

    accounts = get_all_active_accounts()
        Enum.each(accounts, fn account ->
      datapoint = Accounts.get_latest_account_datapoint(account)
      generate_hiscores(datapoint)
    end)
  end

  defp get_all_active_accounts() do
    Repo.all(
      from(
        a in Account,
        where: a.is_combatless == true and a.is_on_hiscores == true and a.is_abandoned == false
      )
    )
  end
end
