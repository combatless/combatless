defmodule Combatless.SiteUsers.SiteUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Combatless.SiteUsers.SiteUser


  schema "site_users" do
    field :avatar_url, :string
    field :is_admin, :boolean, default: false
    field :is_mod, :boolean, default: false
    field :slug, :string
    field :twitter_id, :string

    timestamps()
  end

  @doc false
  def changeset(%SiteUser{} = site_user, attrs) do
    site_user
    |> cast(attrs, [:twitter_id, :slug, :avatar_url, :is_mod, :is_admin])
    |> validate_required([:twitter_id, :slug, :avatar_url, :is_mod, :is_admin])
  end
end
