defmodule CombatlessWeb.Auth.SiteUserSession do
  import Plug.Conn
  alias Combatless.Repo
  alias Combatless.SiteUsers
  alias Combatless.SiteUsers.SiteUser

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil -> load_current_user(conn)
      conn -> conn
    end
  end

  def login_user(conn, site_user) do
    conn
    |> put_session(:user_id, site_user.id)
    |> assign(:current_user, SiteUsers.get_site_user_safe_info(site_user))
  end

  def logout(conn) do
    conn
    |> delete_session(:user_id)
    |> assign(:current_user, nil)
  end

  def current_user(conn) do
    conn.assigns[:current_user] || load_current_user(conn)
  end

  defp load_current_user(conn) do
    id = get_session(conn, :user_id)
    if id do
      user = Repo.get!(SiteUser, id)
      login_user(conn, user)
    else
      conn
    end
  end
end
