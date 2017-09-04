defmodule Combatless.Repo.Migrations.CreateDatapoints do
  use Ecto.Migration

  def change do
    create table(:datapoints) do
      add :fetched_at, :utc_datetime
      add :is_valid, :boolean, default: true, null: false
      add :ehp_version, :integer
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:datapoints, [:account_id])
  end
end
