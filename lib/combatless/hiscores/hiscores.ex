defmodule Combatless.Hiscores do
  @moduledoc """
  The Hiscores context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo
  alias Combatless.Datapoints.Datapoint
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
