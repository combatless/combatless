defmodule Combatless.Datapoints.Skill do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Datapoints.Skill
  alias Combatless.Datapoints.SkillDatapoint


  schema "skills" do
    field :name, :string
    field :slug, :string
    has_many :skill_datapoints, SkillDatapoint
    has_many :hiscores, Combatless.Hiscores.Hiscore
  end

  @doc false
  def changeset(%Skill{} = skill, attrs) do
    skill
    |> cast(attrs, [:slug, :name])
    |> validate_required([:slug, :name])
  end
end
