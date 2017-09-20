defmodule Combatless.Accounts do
  @moduledoc """
  The Accounts context.
  """

  @active_account_attrs %{is_combatless: true, is_on_hiscores: true, is_abandoned: false}

  import Ecto.Query, warn: false
  alias Combatless.Repo

  alias Combatless.Accounts.Account
  alias Combatless.Datapoints
  alias Combatless.Datapoints.Datapoint
  alias Combatless.OSRS.Hiscores.Hiscore
  alias Combatless.OSRS
  alias Combatless.OSRS.EHP
  alias Combatless.Accounts.Profile

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Gets a single active account by name.

  Returns result or nil if none found.

  ## Examples

      iex> get_active_account("bitwise")
      %Account{}

      iex> get_active_account("bea5")
      nil
  """
  def get_active_account(name) do
    active = Map.put_new(@active_account_attrs, :name, name)
    Repo.get_by(Account, active)
  end


  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{source: %Account{}}

  """
  def change_account(%Account{} = account) do
    Account.changeset(account, %{})
  end

  @doc """
  Strips a string of all non-valid runescape username characters, returns nil if input is nil
  """
  def format_account_name(nil), do: nil
  def format_account_name(%Account{} = account), do: format_account_name(account.name)
  def format_account_name(name) do
    name
    |> String.downcase()
    |> String.trim()
    |> String.replace(~r/[^a-zA-Z\d\ \-\_:]/, "")
    |> String.replace(~r/ |-/, "_")
  end

  def printable_account_name(name) do
    name
    |> String.split([" ", "_"])
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  def new_account_changeset(name), do: Account.changeset(%Account{}, %{name: name})


  def activate_account(account, attrs \\ @active_account_attrs) do
    update_account(account, attrs)
  end

  def get_all_accounts_last_fetched_at() do
    Repo.all(
      from a in Account,
      join: d in Datapoint,
      on: d.account_id == a.id,
      group_by: a.id,
      having: a.is_combatless == true,
      select: {a.id, max(d.fetched_at)}
    )
  end

  defp validate_combat_level(%Hiscore{} = hiscore) do
    case OSRS.combat_level(hiscore) do
      level when level < 4 -> :ok
      _ -> {:error, :not_combatless}
    end
  end

  defp validate_cooldown_time(nil, _), do: :ok
  defp validate_cooldown_time(%Datapoint{} = latest_datapoint, time) do
    case Timex.diff time, latest_datapoint.fetched_at, :seconds do
      diff when diff > 30 -> :ok
      _ -> {:error, :cooldown_active}
    end
  end


  def get_latest_account_datapoint(%Account{} = account) do
    Repo.one(
      from d in Datapoints.full_datapoint_query(),
      where: d.is_valid == true and d.account_id == ^account.id,
      order_by: [
        desc: d.fetched_at
      ],
      limit: 1,
      select: d
    )
  end


  @doc """
  Creates a new datapoint for the account
  """
  def create_account_datapoint(%Account{} = account) do
    alias Combatless.OSRS.Hiscores

    last_datapoint = get_latest_account_datapoint(account)
    time = Timex.now()

    with {:ok, hiscore} <- Hiscores.retrieve(account.name),
         :ok <- validate_combat_level(hiscore),
         :ok <- validate_cooldown_time(last_datapoint, time) do
      {ehp_version, hiscore_with_ehp} = EHP.calculate(hiscore)
      %Datapoint{fetched_at: time, account_id: account.id, ehp_version: ehp_version}
      |> Datapoints.from_hiscore(hiscore_with_ehp)
      |> Repo.insert()
      |> Combatless.Hiscores.generate_hiscores()
    end
  end

  def get_account_profile(account, period) do
    now = Timex.now()
    starting_time = if period == :all, do: Timex.epoch(), else: Timex.shift(now, period_to_arbitrary_days(period))

    case get_furthest_datapoints(account, now, starting_time) do
      {nil, nil} -> get_latest_profile_without_period(account, now, starting_time)
      {%Datapoint{} = most_recent, %Datapoint{} = least_recent} ->
        most_recent_hiscore = Datapoints.datapoint_to_hiscore(most_recent)
        least_recent_hiscore = Datapoints.datapoint_to_hiscore(least_recent)
        hiscore_diff = Datapoints.diff_hiscores(most_recent_hiscore, least_recent_hiscore)

        %Profile{
          account: account,
          has_diff?: true,
          times: %{
            now: now,
            starting_time: starting_time
          },
          datapoints: %{
            most_recent: most_recent,
            least_recent: least_recent
          },
          hiscores: %{
            most_recent: most_recent_hiscore,
            least_recent: least_recent_hiscore,
            diff: hiscore_diff
          }
        }
    end
  end

  def get_latest_profile_without_period(account, now, starting_time) do
    case get_latest_account_datapoint(account) do
      nil ->
        %Profile{
          account: account,
          has_diff?: false,
          times: %{
            now: now,
            starting_time: starting_time
          },
          datapoints: nil,
          hiscores: nil
        }
      %Datapoint{} = latest ->
        %Profile{
          account: account,
          has_diff?: false,
          times: %{
            now: now,
            starting_time: starting_time
          },
          datapoints: %{
            most_recent: latest
          },
          hiscores: %{
            most_recent: Datapoints.datapoint_to_hiscore(latest)
          }
        }
    end
  end

  def get_furthest_datapoints(account, now, starting_time) do
    account_datapoints_query =
      from d in Datapoints.full_datapoint_query(),
           where: d.is_valid == true and d.account_id == ^account.id and d.fetched_at > ^starting_time,
           limit: 1,
           select: d

    most_recent =
      Repo.one(
        from d in account_datapoints_query,
        order_by: [
          desc: d.fetched_at
        ]
      )

    least_recent =
      Repo.one(
        from d in account_datapoints_query,
        order_by: [
          asc: d.fetched_at
        ]
      )

    {most_recent, least_recent}
  end

  defp period_to_arbitrary_days(:week), do: [days: -7]
  defp period_to_arbitrary_days(:month), do: [days: -30]
  defp period_to_arbitrary_days(:year), do: [days: -365]

  #def get_account_profile(account, time_period) do
  #  datapoints = Repo.all(from dps in Datapoints.full_datapoint_query(account))
  #  furthest = Datapoints.get_furthest_datapoints(datapoints)
  #  %Profile{account: account, datapoints: furthest}
  #end

  alias Combatless.Accounts.NameChange

  @doc """
  Returns the list of name_changes.

  ## Examples

      iex> list_name_changes()
      [%NameChange{}, ...]

  """
  def list_name_changes do
    Repo.all(NameChange)
  end

  @doc """
  Gets a single name_change.

  Raises `Ecto.NoResultsError` if the Name change does not exist.

  ## Examples

      iex> get_name_change!(123)
      %NameChange{}

      iex> get_name_change!(456)
      ** (Ecto.NoResultsError)

  """
  def get_name_change!(id), do: Repo.get!(NameChange, id)

  @doc """
  Creates a name_change.

  ## Examples

      iex> create_name_change(%{field: value})
      {:ok, %NameChange{}}

      iex> create_name_change(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_name_change(attrs \\ %{}) do
    %NameChange{}
    |> NameChange.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a name_change.

  ## Examples

      iex> update_name_change(name_change, %{field: new_value})
      {:ok, %NameChange{}}

      iex> update_name_change(name_change, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_name_change(%NameChange{} = name_change, attrs) do
    name_change
    |> NameChange.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a NameChange.

  ## Examples

      iex> delete_name_change(name_change)
      {:ok, %NameChange{}}

      iex> delete_name_change(name_change)
      {:error, %Ecto.Changeset{}}

  """
  def delete_name_change(%NameChange{} = name_change) do
    Repo.delete(name_change)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking name_change changes.

  ## Examples

      iex> change_name_change(name_change)
      %Ecto.Changeset{source: %NameChange{}}

  """
  def change_name_change(%NameChange{} = name_change) do
    NameChange.changeset(name_change, %{})
  end
end
