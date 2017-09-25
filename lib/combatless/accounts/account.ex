defmodule Combatless.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Accounts
  alias Combatless.Accounts.Account
  alias Combatless.Datapoints.Datapoint
  alias Combatless.SiteUsers.SiteUser
  alias Combatless.Hiscores.Hiscore

  @timestamps_opts [
    type: Timex.Ecto.DateTime,
    autogenerate: {Timex.Ecto.DateTime, :autogenerate, []}
  ]

  schema "accounts" do
    field :is_abandoned, :boolean, default: false
    field :is_combatless, :boolean, default: false
    field :is_on_hiscores, :boolean, default: false
    field :name, :string, null: false
    field :old_name, :string
    field :settings, :map, null: false, default: %{}
    has_many :datapoints, Datapoint
    field :hiscores, {:array, Hiscore}, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%Account{} = account, attrs) do
    account
    |> cast(attrs, [:name, :old_name, :is_abandoned, :is_on_hiscores, :is_combatless, :settings])
    |> validate_required([:name])
    |> format_names()
    |> unique_constraint(:name, name: :accounts_name_is_combatless_index)
    |> validate_format(:name, ~r(^[\w- ]+$), message: "is an invalid player name")
    |> validate_length(:name, min: 1, max: 12)
  end

  defp format_names(%Ecto.Changeset{valid?: false} = changeset), do: changeset
  defp format_names(%Ecto.Changeset{valid?: true} = changeset) do
    formatted_name =
      changeset
      |> get_field(:name)
      |> Accounts.format_account_name()

    formatted_old_name =
      changeset
      |> get_field(:old_name)
      |> Accounts.format_account_name()

    changeset
    |> put_change(:name, formatted_name)
    |> put_change(:old_name, formatted_old_name)
  end
end
