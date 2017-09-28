defmodule CombatlessWeb.CurrentTopController do
  use CombatlessWeb, :controller

  import Combatless.Utils, only: [period_to_arbitrary_days: 1]
  alias Combatless.CurrentTops
  alias Combatless.Repo

  @allowed_skills ~w(overall cooking woodcutting fletching fishing
                    firemaking crafting smithing mining herblore
                    agility thieving farming runecraft hunter
                    construction ehp)

  defp generate_current_top(skill, params, periods) do
    now = Timex.now()
    Enum.reduce(periods, %{}, fn period, acc ->
      data =
        skill
        |> CurrentTops.current_top(period)
        |> Repo.paginate(params)

      Map.put(acc, period, data)
      end
    )
  end

  def index(conn, %{"skill" => skill} = params) when skill in @allowed_skills do
    current_tops = generate_current_top(skill, params, [:day, :week, :month, :year])

    render(conn, "index.html", page: current_tops.year, current_tops: current_tops, skill: skill)
  end

  def index(conn, params) do
    index(conn, Map.put(params, "skill", "ehp"))
  end
end
