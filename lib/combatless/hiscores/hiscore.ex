defmodule Combatless.Hiscores.Hiscore do
  use Ecto.Schema

  import Ecto.Changeset
  alias Combatless.Hiscores.Hiscore
  alias Combatless.Accounts.Account
  alias Combatless.Datapoints.Skill

  schema "hiscores" do
    belongs_to :account, Account
    belongs_to :skill, Skill
    field :value, :float, null: false
    field :rank, :integer
    field :current, :float, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%Hiscore{} = hiscore, attrs) do
    hiscore
    |> cast(attrs, [:account_id, :skill_id, :value, :rank])
    |> validate_required([:account_id, :skill_id, :value, :rank])
  end
end
