defmodule CombatlessWeb.Auth.Narnode do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias Combatless.SiteUsers

  def init(opts) do
    Keyword.fetch!(opts, :allow)
  end

  def call(conn, allow) when is_list(allow) do
    case get_session(conn, :current_user) do
      nil -> not_logged_in(conn)
      current_user -> compare_ranks(conn, current_user, allow)
    end
  end

  defp compare_ranks(conn, current_user, allow) do
    rank = SiteUsers.get_site_users_rank(current_user.id)
    case rank in allow do
      true -> conn
      false -> not_authorized(conn)
    end
  end

  defp not_authorized(conn) do
    conn
    |> put_flash(:error, "You do not have sufficient permission to access this page.")
    |> redirect(to: "/")
    |> halt()
  end

  defp not_logged_in(conn) do
    conn
    |> put_flash(:error, "You must be logged in to access this page.")
    |> redirect(to: "/")
    |> halt()
  end
end
