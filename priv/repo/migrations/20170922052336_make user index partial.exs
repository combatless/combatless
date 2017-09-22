defmodule :"Elixir.Combatless.Repo.Migrations.Make user index partial" do
  use Ecto.Migration

  def change do
    drop unique_index(:accounts, [:name, :is_combatless])
    create unique_index(:accounts, [:name, :is_combatless], where: "is_combatless = true")
  end
end
