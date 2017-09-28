defmodule Combatless.Datapoints do
  @moduledoc """
  The Datapoints context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo

  alias Combatless.Datapoints.Datapoint
  alias Combatless.Datapoints.Skill
  alias Combatless.Datapoints.SkillDatapoint
  alias Combatless.OSRS.Hiscores.Hiscore

  @doc """
  Returns the list of datapoints.

  ## Examples

      iex> list_datapoints()
      [%Datapoint{}, ...]

  """
  def list_datapoints do
    Repo.all(Datapoint)
  end

  @doc """
  Gets a single datapoint.

  Raises `Ecto.NoResultsError` if the Datapoint does not exist.

  ## Examples

      iex> get_datapoint!(123)
      %Datapoint{}

      iex> get_datapoint!(456)
      ** (Ecto.NoResultsError)

  """
  def get_datapoint!(id), do: Repo.get!(Datapoint, id)

  @doc """
  Creates a datapoint.

  ## Examples

      iex> create_datapoint(%{field: value})
      {:ok, %Datapoint{}}

      iex> create_datapoint(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_datapoint(attrs \\ %{}) do
    %Datapoint{}
    |> Datapoint.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a datapoint.

  ## Examples

      iex> update_datapoint(datapoint, %{field: new_value})
      {:ok, %Datapoint{}}

      iex> update_datapoint(datapoint, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_datapoint(%Datapoint{} = datapoint, attrs) do
    datapoint
    |> Datapoint.changeset(attrs)
    |> Repo.update()
  end

  def insert_datapoint_changeset(%Ecto.Changeset{} = datapoint_changeset) do
    Repo.insert(datapoint_changeset)
  end

  @doc """
  Deletes a Datapoint.

  ## Examples

      iex> delete_datapoint(datapoint)
      {:ok, %Datapoint{}}

      iex> delete_datapoint(datapoint)
      {:error, %Ecto.Changeset{}}

  """
  def delete_datapoint(%Datapoint{} = datapoint) do
    Repo.delete(datapoint)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking datapoint changes.

  ## Examples

      iex> change_datapoint(datapoint)
      %Ecto.Changeset{source: %Datapoint{}}

  """
  def change_datapoint(%Datapoint{} = datapoint) do
    Datapoint.changeset(datapoint, %{})
  end

  @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills()
      [%Skill{}, ...]

  """
  def list_skills() do
    Repo.all(Skill)
  end

  def get_unique_account_datapoints() do
    from(d in Datapoint,
      distinct: d.account_id,
      order_by: [
        desc: d.fetched_at
      ]
    )
  end

  def get_unique_skill_datapoints() do
    from(sd in SkillDatapoint,
      join: d in assoc(sd, :datapoint),
      distinct: d.account_id,
      order_by: [
        desc: d.fetched_at
      ],
      select: sd
    )
  end


  def skill_datapoints_query() do
    from sd in SkillDatapoint,
         join: s in assoc(sd, :skill),
         preload: [
           skill: s
         ]
  end


  def full_datapoint_query() do
    from d in Datapoint,
         preload: [
           skill_datapoints: ^skill_datapoints_query()
         ]
  end

  def from_hiscore(%Datapoint{} = datapoint, %Hiscore{} = hiscore) do
    skills = list_skills()

    skill_datapoints =
      Enum.map(
        skills,
        fn column ->
          Ecto.build_assoc(column, :skill_datapoints, Map.get(hiscore, String.to_atom(column.slug)))
        end
      )

    datapoint
    |> change_datapoint()
    |> Ecto.Changeset.put_assoc(:skill_datapoints, skill_datapoints)
  end

  def get_furthest_datapoints(datapoints) do
    [first | tail] = datapoints
    last =
      if Enum.empty?(tail) do
        first
      else
        tail
        |> Enum.reverse()
        |> List.first()
      end
    [first, last]
  end

  def datapoint_to_hiscore(%Datapoint{} = datapoint) do
    Enum.reduce(datapoint.skill_datapoints, %Hiscore{}, fn skill_datapoint, hiscore ->
      {slug, data} = skill_datapoint_to_skill_map(skill_datapoint)
      Map.put(hiscore, slug, data)
    end)
  end

  defp skill_datapoint_to_skill_map(%SkillDatapoint{} = skill_datapoint) do
    data = Map.take(skill_datapoint, [:rank, :level, :xp, :virtual_level, :ehp])
    slug = String.to_atom(skill_datapoint.skill.slug)
    {slug, data}
  end

  def diff_hiscores(most_recent, least_recent) do
    most_recent
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.reduce(%Hiscore{}, fn skill, hiscore ->
      lhs = Map.get(most_recent, skill)
      rhs = Map.get(least_recent, skill)
      diff = Map.merge(lhs, rhs, fn (_skill, l, r) -> l - r end)
      %{hiscore | skill => diff}
    end)
  end
end
