defmodule :"Elixir.Combatless.Repo.Migrations.Remove hiscores table" do
  use Ecto.Migration

  def change do
    drop table(:hiscores)
  end
end
