defmodule CombatlessWeb.GraphController do
  use CombatlessWeb, :controller

  alias Combatless.Graphs
  alias Combatless.Datapoints
  alias Combatless.Repo
  alias Combatless.Utils

  @time_periods ["day", "week", "month", "year", "all"]


  def ehp(conn, %{"id" => id, "period" => period}) when period in @time_periods do
    import Ecto.Query, warn: false

    now = Timex.now()
    period = String.to_atom(period)
    starting_time = if period == :all, do: Timex.epoch(), else: Timex.shift(now, Utils.period_to_arbitrary_days(period))
    datapoints = Graphs.get_datapoints(:ehp, id, skill: "overall", from: starting_time)
    render(conn, "ehp.json", datapoints: datapoints)
  end
end
