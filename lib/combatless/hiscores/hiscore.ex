defmodule Combatless.Hiscores.Hiscore do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Hiscores.Hiscore
  alias Combatless.Accounts.Account
  alias Combatless.Datapoints.Datapoint
  alias Combatless.Datapoints.Skill
  alias Combatless.Datapoints.SkillDatapoint

  schema "hiscores" do
    #field :account_id, :id
    #field :datapoint_id, :id
    #field :skill_id, :id
    #field :skill_datapoint_id, :id
    belongs_to :account, Account
    belongs_to :datapoint, Datapoint
    belongs_to :skill, Skill
    belongs_to :skill_datapoint, SkillDatapoint

    timestamps()
  end

  @doc false
  def changeset(%Hiscore{} = hiscore, attrs) do
    hiscore
    |> cast(attrs, [:account_id, :datapoint_id, :skill_id, :skill_datapoint_id])
    |> validate_required([])
  end
end
