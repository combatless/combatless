defmodule CombatlessWeb.SiteUserControllerTest do
  use CombatlessWeb.ConnCase

  alias Combatless.SiteUsers

  @create_attrs %{avatar_url: "some avatar_url", is_admin: true, is_mod: true, slug: "some slug", twitter_id: "some twitter_id"}
  @update_attrs %{avatar_url: "some updated avatar_url", is_admin: false, is_mod: false, slug: "some updated slug", twitter_id: "some updated twitter_id"}
  @invalid_attrs %{avatar_url: nil, is_admin: nil, is_mod: nil, slug: nil, twitter_id: nil}

  def fixture(:site_user) do
    {:ok, site_user} = SiteUsers.create_site_user(@create_attrs)
    site_user
  end

  describe "index" do
    test "lists all site_users", %{conn: conn} do
      conn = get conn, site_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Site users"
    end
  end

  describe "new site_user" do
    test "renders form", %{conn: conn} do
      conn = get conn, site_user_path(conn, :new)
      assert html_response(conn, 200) =~ "New Site user"
    end
  end

  describe "create site_user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, site_user_path(conn, :create), site_user: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == site_user_path(conn, :show, id)

      conn = get conn, site_user_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Site user"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, site_user_path(conn, :create), site_user: @invalid_attrs
      assert html_response(conn, 200) =~ "New Site user"
    end
  end

  describe "edit site_user" do
    setup [:create_site_user]

    test "renders form for editing chosen site_user", %{conn: conn, site_user: site_user} do
      conn = get conn, site_user_path(conn, :edit, site_user)
      assert html_response(conn, 200) =~ "Edit Site user"
    end
  end

  describe "update site_user" do
    setup [:create_site_user]

    test "redirects when data is valid", %{conn: conn, site_user: site_user} do
      conn = put conn, site_user_path(conn, :update, site_user), site_user: @update_attrs
      assert redirected_to(conn) == site_user_path(conn, :show, site_user)

      conn = get conn, site_user_path(conn, :show, site_user)
      assert html_response(conn, 200) =~ "some updated avatar_url"
    end

    test "renders errors when data is invalid", %{conn: conn, site_user: site_user} do
      conn = put conn, site_user_path(conn, :update, site_user), site_user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Site user"
    end
  end

  describe "delete site_user" do
    setup [:create_site_user]

    test "deletes chosen site_user", %{conn: conn, site_user: site_user} do
      conn = delete conn, site_user_path(conn, :delete, site_user)
      assert redirected_to(conn) == site_user_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, site_user_path(conn, :show, site_user)
      end
    end
  end

  defp create_site_user(_) do
    site_user = fixture(:site_user)
    {:ok, site_user: site_user}
  end
end
