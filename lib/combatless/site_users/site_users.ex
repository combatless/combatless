defmodule Combatless.SiteUsers do
  @moduledoc """
  The SiteUsers context.
  """

  import Ecto.Query, warn: false
  alias Combatless.Repo

  alias Combatless.SiteUsers.SiteUser
  alias Ueberauth.Auth
  alias Ueberauth.Strategy.Twitter

  @safe_site_user_info [:id, :twitter_id, :slug, :avatar_url]


  @doc """
  Returns the list of site_users.

  ## Examples

      iex> list_site_users()
      [%SiteUser{}, ...]

  """
  def list_site_users do
    Repo.all(SiteUser)
  end

  @doc """
  Gets a single site_user.

  Raises `Ecto.NoResultsError` if the Site user does not exist.

  ## Examples

      iex> get_site_user!(123)
      %SiteUser{}

      iex> get_site_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_site_user!(id), do: Repo.get!(SiteUser, id)

  @doc """
  Gets a single site_user based on fields passed to it.
  """
  def get_site_user_by(fields), do: Repo.get_by(SiteUser, fields)

  @doc """
  Creates a site_user.

  ## Examples

      iex> create_site_user(%{field: value})
      {:ok, %SiteUser{}}

      iex> create_site_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_site_user(attrs \\ %{}) do
    %SiteUser{}
    |> SiteUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a site_user.

  ## Examples

      iex> update_site_user(site_user, %{field: new_value})
      {:ok, %SiteUser{}}

      iex> update_site_user(site_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_site_user(%SiteUser{} = site_user, attrs) do
    site_user
    |> SiteUser.changeset(attrs)
    |> Repo.update()
    |> case do
         {:ok, site_user} ->
           :ok = ConCache.delete(:site_users_ranks, site_user.id)
           {:ok, site_user}
         error -> error
       end
  end

  @doc """
  Deletes a SiteUser.

  ## Examples

      iex> delete_site_user(site_user)
      {:ok, %SiteUser{}}

      iex> delete_site_user(site_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_site_user(%SiteUser{} = site_user) do
    ConCache.delete(:site_users_ranks, site_user.id)
    Repo.delete(site_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking site_user changes.

  ## Examples

      iex> change_site_user(site_user)
      %Ecto.Changeset{source: %SiteUser{}}

  """
  def change_site_user(%SiteUser{} = site_user) do
    SiteUser.changeset(site_user, %{})
  end

  @doc """
  Upserts the user information in order to both create new site users
  and update existing site users' twitter info every time they log in.
  """
  def create_or_update_site_user(user_info) do
    case get_site_user_by(twitter_id: user_info.twitter_id) do
      %SiteUser{} = site_user -> update_site_user(site_user, user_info)
      nil -> create_site_user(user_info)
    end
  end

  @doc """
  Database keys that wouldn't hurt me not being able to change or cancel in the
  future.  Basically permissions == bad and commmonly accessed info == good
  """
  def get_site_user_safe_info(%SiteUser{} = site_user), do: Map.take(site_user, @safe_site_user_info)

  @doc """
  Strips Twitter user information from oauth callback.
  """
  def extract_from_auth(%Auth{strategy: Twitter} = auth) do
    info = auth.extra.raw_info.user
    %{
      slug: info["screen_name"],
      twitter_id: Integer.to_string(info["id"]),
      avatar_url: info["profile_image_url_https"]
    }
  end

  @doc """
  Gets the users rank from cache based on id, or the database incase it is not in cache.
  """
  def get_site_users_rank(%SiteUser{} = site_user), do: get_site_users_rank(site_user.id)
  def get_site_users_rank(site_user_id) do
    ConCache.get_or_store(:site_users_ranks, site_user_id, fn ->
      site_user_id
      |> get_site_user!()
      |> case do
           %SiteUser{is_admin: true} -> :admin
           %SiteUser{is_mod: true} -> :mod
           _ -> :user
         end
    end)
  end

end
