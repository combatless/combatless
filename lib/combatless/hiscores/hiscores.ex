defmodule Combatless.Hiscores do
  @moduledoc """
  The Hiscores context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo
  alias Combatless.Datapoints
  alias Combatless.Datapoints.Datapoint
  alias Combatless.Accounts.Account
  alias Ecto.Multi

  alias Combatless.Hiscores.Hiscore

  @doc """
  Returns the list of hiscores.

  ## Examples

      iex> list_hiscores()
      [%Hiscore{}, ...]

  """
  def list_hiscores do
    Repo.all(Hiscore)
  end

  @doc """
  Gets a single hiscore.

  Raises `Ecto.NoResultsError` if the Hiscore does not exist.

  ## Examples

      iex> get_hiscore!(123)
      %Hiscore{}

      iex> get_hiscore!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hiscore!(id), do: Repo.get!(Hiscore, id)

  @doc """
  Creates a hiscore.

  ## Examples

      iex> create_hiscore(%{field: value})
      {:ok, %Hiscore{}}

      iex> create_hiscore(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hiscore(attrs \\ %{}) do
    %Hiscore{}
    |> Hiscore.changeset(attrs)
    |> Repo.insert(conflict_target: [:account_id, :skill_id], on_conflict: :replace_all)
  end

  @doc """
  Updates a hiscore.

  ## Examples

      iex> update_hiscore(hiscore, %{field: new_value})
      {:ok, %Hiscore{}}

      iex> update_hiscore(hiscore, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hiscore(%Hiscore{} = hiscore, attrs) do
    hiscore
    |> Hiscore.changeset(attrs)
    |> Repo.update(conflict_target: [:account_id, :skill_id], on_conflict: :replace_all)
  end

  @doc """
  Deletes a Hiscore.

  ## Examples

      iex> delete_hiscore(hiscore)
      {:ok, %Hiscore{}}

      iex> delete_hiscore(hiscore)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hiscore(%Hiscore{} = hiscore) do
    Repo.delete(hiscore)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hiscore changes.

  ## Examples

      iex> change_hiscore(hiscore)
      %Ecto.Changeset{source: %Hiscore{}}

  """
  def change_hiscore(%Hiscore{} = hiscore) do
    Hiscore.changeset(hiscore, %{})
  end

  def user_preload(%Account{} = account) do
    ##Repo.one(
    ##  from a in Account,
    ##    join: h in assoc(a, :hiscores),
    ##    join: sd in assoc(h, :skill_datapoint),
    ##    join: s in assoc(h, :skill),
    ##    preload: [hiscores: {h, [skill_datapoint: sd, skill: s]}],
    ##    where: a.id == ^account.id
    ##)
    Repo.preload(account, [hiscores: [:skill_datapoint, :skill]])
  end

  def active_hiscores_data_query(skill) do
    from([h, sd, s, a] in active_hiscores_query(skill),
      preload: [skill_datapoint: sd, account: a]
    )
  end

  def active_hiscores_query(skill) do
    real_skill = if skill == "ehp", do: "overall", else: skill

    from(h in Hiscore,
      join: sd in assoc(h, :skill_datapoint),
      join: s in assoc(h, :skill),
      join: a in assoc(h, :account),
      where: s.slug == ^real_skill and a.is_combatless == true and sd.rank > 0,
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
      |> user_preload()
      |> Map.get(:hiscores)
      |> Enum.find(& &1.skill.slug == real_skill)
      |> Map.get(:skill_datapoint)

    skill
    |> active_hiscores_query()
    |> skill_rank(skill, skill_datapoint)
    |> Repo.aggregate(:count, :id)
    |> Kernel.+(1)
  end

  def skill_rank(query, "ehp", user_sd), do: from [h, sd] in query, where: sd.ehp > ^user_sd.ehp
  def skill_rank(query, "overall", user_sd), do: from [h, sd] in query, where: sd.virtual_level > ^user_sd.virtual_level
  def skill_rank(query, _, user_sd), do: from [h, sd] in query, where: sd.rank < ^user_sd.rank

  @spec generate_hiscores(%Datapoint{} | {atom, any}) :: {:ok | :error, any}
  def generate_hiscores({:error, error}), do: {:error, error}
  def generate_hiscores({:ok, %Datapoint{} = datapoint}), do: generate_hiscores(datapoint)
  def generate_hiscores(%Datapoint{} = datapoint) do
    Repo.transaction(fn -> do_generate_hiscores(datapoint) end)
  end

  def get_ranks(%Account{} = account) do
    account = user_preload(account)

    account
    |> Map.get(:hiscores)
    |> Enum.reduce(%{}, fn hiscore, acc ->
      skill = hiscore.skill.slug
      rank = if hiscore.skill_datapoint.rank > 0, do: get_rank(account, skill), else: -1
      Map.put(acc, String.to_atom(skill), rank)
    end)
  end

  defp do_generate_hiscores(%Datapoint{} = datapoint) do
    Enum.each(
      datapoint.skill_datapoints,
      fn skill_datapoint ->
        create_hiscore(
          %{
            account_id: datapoint.account_id,
            datapoint_id: datapoint.id,
            skill_id: skill_datapoint.skill_id,
            skill_datapoint_id: skill_datapoint.id
          }
        )
      end
    )
  end
end
