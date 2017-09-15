defmodule CombatlessWeb.Admin.SiteUserController do
  use CombatlessWeb, :controller

  alias Combatless.SiteUsers
  alias Combatless.SiteUsers.SiteUser

  def index(conn, _params) do
    site_users = SiteUsers.list_site_users()
    render(conn, "index.html", site_users: site_users)
  end

  def new(conn, _params) do
    changeset = SiteUsers.change_site_user(%SiteUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"site_user" => site_user_params}) do
    case SiteUsers.create_site_user(site_user_params) do
      {:ok, site_user} ->
        conn
        |> put_flash(:info, "Site user created successfully.")
        |> redirect(to: site_user_path(conn, :show, site_user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    site_user = SiteUsers.get_site_user!(id)
    render(conn, "show.html", site_user: site_user)
  end

  def edit(conn, %{"id" => id}) do
    site_user = SiteUsers.get_site_user!(id)
    changeset = SiteUsers.change_site_user(site_user)
    render(conn, "edit.html", site_user: site_user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "site_user" => site_user_params}) do
    site_user = SiteUsers.get_site_user!(id)

    case SiteUsers.update_site_user(site_user, site_user_params) do
      {:ok, site_user} ->
        conn
        |> put_flash(:info, "Site user updated successfully.")
        |> redirect(to: site_user_path(conn, :show, site_user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", site_user: site_user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    site_user = SiteUsers.get_site_user!(id)
    {:ok, _site_user} = SiteUsers.delete_site_user(site_user)

    conn
    |> put_flash(:info, "Site user deleted successfully.")
    |> redirect(to: site_user_path(conn, :index))
  end
end
