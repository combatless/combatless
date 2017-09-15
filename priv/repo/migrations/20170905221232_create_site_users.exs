defmodule Combatless.Repo.Migrations.CreateSiteUsers do
  use Ecto.Migration

  def change do
    create table(:site_users) do
      add :twitter_id, :string
      add :slug, :string
      add :avatar_url, :string
      add :is_mod, :boolean, default: false, null: false
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:site_users, [:twitter_id])
  end
end
