defmodule Combatless.Datapoints.Datapoint do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Datapoints.Datapoint
  alias Combatless.Datapoints.SkillDatapoint
  alias Combatless.Accounts.Account

  @timestamps_opts [
    type: Timex.Ecto.DateTime,
    autogenerate: {Timex.Ecto.DateTime, :autogenerate, []}
  ]


  schema "datapoints" do
    field :ehp_version, :integer
    field :fetched_at, Timex.Ecto.DateTime
    field :is_valid, :boolean, default: true
    belongs_to :account, Account
    has_many :skill_datapoints, SkillDatapoint
    has_many :hiscore, Combatless.Hiscores.Hiscore

    timestamps()
  end

  @doc false
  def changeset(%Datapoint{} = datapoint, attrs) do
    datapoint
    |> cast(attrs, [:fetched_at, :is_valid, :ehp_version])
    |> validate_required([:fetched_at, :is_valid, :ehp_version])
  end
end
