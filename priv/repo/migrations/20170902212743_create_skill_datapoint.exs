defmodule Combatless.Repo.Migrations.CreateSkillDatapoint do
  use Ecto.Migration

  def change do
    create table(:skill_datapoint) do
      add :xp, :integer
      add :rank, :integer
      add :level, :integer
      add :virtual_level, :integer
      add :ehp, :float
      add :datapoint_id, references(:datapoints, on_delete: :nothing)
      add :skill_id, references(:skills, on_delete: :nothing)

      timestamps()
    end

    create index(:skill_datapoint, [:datapoint_id])
    create index(:skill_datapoint, [:skill_id])
    create unique_index(:skill_datapoint, [:datapoint_id, :skill_id])
  end
end
