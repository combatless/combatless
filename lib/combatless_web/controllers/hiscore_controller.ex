defmodule CombatlessWeb.HiscoreController do
  use CombatlessWeb, :controller

  alias Combatless.Hiscores

  @allowed_skills ~w(overall cooking woodcutting fletching fishing
                    firemaking crafting smithing mining herblore
                    agility thieving farming runecraft hunter
                    construction ehp)

  def index(conn, %{"skill" => skill} = params) when skill in @allowed_skills do
    page =
      skill
      |> Hiscores.active_hiscores_query()
      |> Combatless.Repo.paginate(params)

    render(conn, "index.html", page: page, skill: skill)
  end

  def index(conn, params) do
    index(conn, Map.put(params, "skill", "ehp"))
  end
end
