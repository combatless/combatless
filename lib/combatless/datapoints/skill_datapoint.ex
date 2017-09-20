defmodule Combatless.Datapoints.SkillDatapoint do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Datapoints.SkillDatapoint
  alias Combatless.Datapoints.Datapoint
  alias Combatless.Datapoints.Skill

  @timestamps_opts [
    type: Timex.Ecto.DateTime,
    autogenerate: {Timex.Ecto.DateTime, :autogenerate, []}
  ]

  schema "skill_datapoint" do
    field :ehp, :float
    field :level, :integer
    field :rank, :integer
    field :virtual_level, :integer
    field :xp, :integer
    belongs_to :datapoint, Datapoint
    belongs_to :skill, Skill
    has_one :hiscore, Combatless.Hiscores.Hiscore

    timestamps()
  end

  @doc false
  def changeset(%SkillDatapoint{} = skill_datapoint, attrs) do
    skill_datapoint
    |> cast(attrs, [:xp, :rank, :level, :virtual_level, :ehp])
    |> validate_required([:xp, :rank, :level, :virtual_level, :ehp])
  end
end
