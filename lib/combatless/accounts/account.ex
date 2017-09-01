defmodule Combatless.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Accounts.Account


  schema "accounts" do
    field :is_abandoned, :boolean, default: false
    field :is_combatless, :boolean, default: false
    field :is_on_hiscores, :boolean, default: false
    field :name, :string
    field :old_name, :string
    field :settings, :map

    timestamps()
  end

  @doc false
  def changeset(%Account{} = account, attrs) do
    account
    |> cast(attrs, [:name, :old_name, :is_abandoned, :is_on_hiscores, :is_combatless, :settings])
    |> validate_required([:name, :old_name, :is_abandoned, :is_on_hiscores, :is_combatless, :settings])
  end
end
