defmodule :"Elixir.Combatless.Repo.Migrations.Add real rank to hiscores table" do
  use Ecto.Migration

  def change do
    alter table("hiscores") do
      add :rank, :integer
    end
  end
end
