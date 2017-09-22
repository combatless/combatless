defmodule Combatless.Accounts.NameChange do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Accounts.NameChange
  alias Combatless.Accounts


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
    |> format_names()
    |> validate_format(:from, ~r(^[\w- ]+$), message: "is an invalid player name")
    |> validate_length(:to, min: 1, max: 12)
    |> validate_format(:to, ~r(^[\w- ]+$), message: "is an invalid player name")
    |> validate_length(:from, min: 1, max: 12)
  end

  defp format_names(%Ecto.Changeset{valid?: false} = changeset), do: changeset
  defp format_names(%Ecto.Changeset{valid?: true} = changeset) do
    from =
      changeset
      |> get_field(:from)
      |> Accounts.format_account_name()

    to =
      changeset
      |> get_field(:to)
      |> Accounts.format_account_name()

    changeset
    |> put_change(:from, from)
    |> put_change(:to, to)
  end
end
