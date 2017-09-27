defmodule CombatlessWeb.GraphView do
  use CombatlessWeb, :view
  alias CombatlessWeb.GraphView
  alias Timex.Format.DateTime.Formatters.Relative

  def render("ehp.json", %{datapoints: datapoints}) do
    %{
      labels: Enum.map(datapoints, & Relative.format!(&1.x, "{relative}")),
      data: Enum.map(datapoints, & &1.y)
    }
  end
end
