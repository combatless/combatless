defmodule Combatless.Graphs do
  import Ecto.Query, warn: false

  alias Combatless.Datapoints.Datapoint
  alias Combatless.Repo

  def get_datapoints(type, account_id, options \\ [])
  def get_datapoints(:ehp, account_id, options) do
    skill = options[:skill]
    from = options[:from]

    from(
      d in Datapoint,
      join: sd in assoc(d, :skill_datapoints),
      join: s in assoc(sd, :skill),
      join: a in assoc(d, :account),
      where: s.slug == ^skill and d.account_id == ^account_id and d.fetched_at > ^from,
      distinct: sd.ehp,
      select: %{
        x: d.fetched_at,
        y: sd.ehp
      }
    )
    |> Repo.all()
  end
end
