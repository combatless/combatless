defmodule Combatless.Accounts.NameChange do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Accounts.NameChange


  schema "name_changes" do
    field :from, :string
    field :is_valid, :boolean, default: false
    field :to, :string

    timestamps()
  end

  @doc false
  def changeset(%NameChange{} = name_change, attrs) do
    name_change
    |> cast(attrs, [:from, :to, :is_valid])
    |> validate_required([:from, :to, :is_valid])
  end
end
