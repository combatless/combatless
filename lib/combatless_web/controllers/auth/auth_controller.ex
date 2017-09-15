defmodule CombatlessWeb.Auth.AuthController do
  use CombatlessWeb, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Combatless.SiteUsers.SiteUser
  alias Combatless.SiteUsers

  def request(conn, _params) do
    redirect conn, to: Helpers.callback_url(conn)
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params), do: failed_login(conn)
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    auth
    |> SiteUsers.extract_from_auth()
    |> SiteUsers.create_or_update_site_user()
    |> case do
         {:ok, %SiteUser{} = site_user} ->
           conn
           |> put_session(:current_user, SiteUsers.get_site_user_safe_info(site_user))
           |> put_flash(:info, "Login successful.")
           |> redirect(to: page_path(conn, :index))
         {:error, _} -> failed_login(conn)
       end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: page_path(conn, :index))
  end

  def failed_login(conn) do
    conn
    |> put_flash(:error, "Login failed")
    |> redirect(to: page_path(conn, :index))
  end
end
