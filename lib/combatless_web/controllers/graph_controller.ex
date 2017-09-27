defmodule CombatlessWeb.GraphController do
  use CombatlessWeb, :controller

  alias Combatless.Graphs
  alias Combatless.Datapoints
  alias Combatless.Repo

  def ehp(conn, %{"id" => id}) do
    import Ecto.Query, warn: false

    now = Timex.now()
    starting_time = Timex.shift(now, days: -7)
    datapoints = Graphs.get_datapoints(:ehp, id, skill: "overall", from: starting_time)
    render(conn, "ehp.json", datapoints: datapoints)
  end
end
