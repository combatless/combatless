defmodule Combatless.Records.TimePeriod do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.Records.TimePeriod


  schema "time_periods" do
    field :name, :string
    field :slug, :string
  end

  @doc false
  def changeset(%TimePeriod{} = time_period, attrs) do
    time_period
    |> cast(attrs, [:slug, :name])
    |> validate_required([:slug, :name])
  end
end
