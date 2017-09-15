defmodule Combatless.Repo.Migrations.CreateNameChanges do
  use Ecto.Migration

  def change do
    create table(:name_changes) do
      add :from, :string
      add :to, :string
      add :is_valid, :boolean, default: false, null: false

      timestamps()
    end

  end
end
