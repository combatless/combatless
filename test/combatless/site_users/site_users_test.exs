defmodule Combatless.SiteUsersTest do
  use Combatless.DataCase

  alias Combatless.SiteUsers

  describe "site_users" do
    alias Combatless.SiteUsers.SiteUser

    @valid_attrs %{avatar_url: "some avatar_url", is_admin: true, is_mod: true, slug: "some slug", twitter_id: "some twitter_id"}
    @update_attrs %{avatar_url: "some updated avatar_url", is_admin: false, is_mod: false, slug: "some updated slug", twitter_id: "some updated twitter_id"}
    @invalid_attrs %{avatar_url: nil, is_admin: nil, is_mod: nil, slug: nil, twitter_id: nil}

    def site_user_fixture(attrs \\ %{}) do
      {:ok, site_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SiteUsers.create_site_user()

      site_user
    end

    test "list_site_users/0 returns all site_users" do
      site_user = site_user_fixture()
      assert SiteUsers.list_site_users() == [site_user]
    end

    test "get_site_user!/1 returns the site_user with given id" do
      site_user = site_user_fixture()
      assert SiteUsers.get_site_user!(site_user.id) == site_user
    end

    test "create_site_user/1 with valid data creates a site_user" do
      assert {:ok, %SiteUser{} = site_user} = SiteUsers.create_site_user(@valid_attrs)
      assert site_user.avatar_url == "some avatar_url"
      assert site_user.is_admin == true
      assert site_user.is_mod == true
      assert site_user.slug == "some slug"
      assert site_user.twitter_id == "some twitter_id"
    end

    test "create_site_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SiteUsers.create_site_user(@invalid_attrs)
    end

    test "update_site_user/2 with valid data updates the site_user" do
      site_user = site_user_fixture()
      assert {:ok, site_user} = SiteUsers.update_site_user(site_user, @update_attrs)
      assert %SiteUser{} = site_user
      assert site_user.avatar_url == "some updated avatar_url"
      assert site_user.is_admin == false
      assert site_user.is_mod == false
      assert site_user.slug == "some updated slug"
      assert site_user.twitter_id == "some updated twitter_id"
    end

    test "update_site_user/2 with invalid data returns error changeset" do
      site_user = site_user_fixture()
      assert {:error, %Ecto.Changeset{}} = SiteUsers.update_site_user(site_user, @invalid_attrs)
      assert site_user == SiteUsers.get_site_user!(site_user.id)
    end

    test "delete_site_user/1 deletes the site_user" do
      site_user = site_user_fixture()
      assert {:ok, %SiteUser{}} = SiteUsers.delete_site_user(site_user)
      assert_raise Ecto.NoResultsError, fn -> SiteUsers.get_site_user!(site_user.id) end
    end

    test "change_site_user/1 returns a site_user changeset" do
      site_user = site_user_fixture()
      assert %Ecto.Changeset{} = SiteUsers.change_site_user(site_user)
    end
  end
end
