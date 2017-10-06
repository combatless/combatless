defmodule Combatless.Repo.Migrations.CreateTimePeriods do
  use Ecto.Migration

  def change do
    create table(:time_periods) do
      add :slug, :string
      add :name, :string
    end

    create index(:time_periods, [:slug])
  end
end
