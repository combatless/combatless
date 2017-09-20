defmodule Combatless.Repo.Migrations.CreateHiscores do
  use Ecto.Migration

  def change do
    create table(:hiscores) do
      add :account_id, references(:accounts, on_delete: :delete_all)
      add :datapoint_id, references(:datapoints, on_delete: :nothing)
      add :skill_id, references(:skills, on_delete: :nothing)
      add :skill_datapoint_id, references(:skill_datapoint, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:hiscores, [:account_id, :skill_id])
    create index(:hiscores, [:datapoint_id])
    create index(:hiscores, [:skill_id])
    create index(:hiscores, [:skill_datapoint_id])
  end
end
