defmodule CombatlessWeb.PageController do
  use CombatlessWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
