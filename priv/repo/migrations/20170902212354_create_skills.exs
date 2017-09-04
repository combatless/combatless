defmodule Combatless.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :slug, :string
      add :name, :string
    end

    create unique_index(:skills, [:slug])
  end
end
