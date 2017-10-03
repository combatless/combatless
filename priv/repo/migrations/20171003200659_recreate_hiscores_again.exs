defmodule Elixir.Combatless.Repo.Migrations.RecreateHiscoresAgain do
  use Ecto.Migration

  def change do
    drop table("hiscores")

    create table(:hiscores) do
      add :account_id, references(:accounts, on_delete: :delete_all)
      add :skill_id, references(:skills, on_delete: :delete_all)
      add :value, :integer, null: false
      add :ehp, :float, null: false
      add :rank, :integer, null: false

      timestamps()
    end

    create unique_index(:hiscores, [:account_id, :skill_id])
    create index(:hiscores, [:skill_id])
    create index(:hiscores, [:value])
    create index(:hiscores, [:rank])
    create index(:hiscores, [:ehp])
  end
end
