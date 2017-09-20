defmodule CombatlessWeb.HiscoreController do
  use CombatlessWeb, :controller

  alias Combatless.Hiscores
  alias Combatless.Hiscores.Hiscore

  def index(conn, _params) do
    hiscores = Hiscores.list_hiscores()
    render(conn, "index.html", hiscores: hiscores)
  end

  def show(conn, %{"id" => id}) do
    hiscore = Hiscores.get_hiscore!(id)
    render(conn, "show.html", hiscore: hiscore)
  end
end
