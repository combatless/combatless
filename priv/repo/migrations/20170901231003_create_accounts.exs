defmodule Combatless.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string
      add :old_name, :string
      add :is_abandoned, :boolean, default: false, null: false
      add :is_on_hiscores, :boolean, default: false, null: false
      add :is_combatless, :boolean, default: false, null: false
      add :settings, :map

      timestamps()
    end

  end
end
