defmodule Combatless.Repo.Migrations.CreateHiscores do
  use Ecto.Migration

  def change do
    create table(:hiscores) do
      add :account_id, references(:accounts, on_delete: :delete_all)
      add :skill_id, references(:skills, on_delete: :delete_all)
      add :value, :float, null: false

      timestamps()
    end

    create unique_index(:hiscores, [:account_id, :skill_id])
    create index(:hiscores, [:skill_id])
  end
end
