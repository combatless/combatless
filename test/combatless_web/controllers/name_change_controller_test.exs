defmodule CombatlessWeb.NameChangeControllerTest do
  use CombatlessWeb.ConnCase

  alias Combatless.Accounts

  @create_attrs %{from: "some from", is_valid: true, to: "some to"}
  @update_attrs %{from: "some updated from", is_valid: false, to: "some updated to"}
  @invalid_attrs %{from: nil, is_valid: nil, to: nil}

  def fixture(:name_change) do
    {:ok, name_change} = Accounts.create_name_change(@create_attrs)
    name_change
  end

  describe "index" do
    test "lists all name_changes", %{conn: conn} do
      conn = get conn, name_change_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Name changes"
    end
  end

  describe "new name_change" do
    test "renders form", %{conn: conn} do
      conn = get conn, name_change_path(conn, :new)
      assert html_response(conn, 200) =~ "New Name change"
    end
  end

  describe "create name_change" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, name_change_path(conn, :create), name_change: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == name_change_path(conn, :show, id)

      conn = get conn, name_change_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Name change"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, name_change_path(conn, :create), name_change: @invalid_attrs
      assert html_response(conn, 200) =~ "New Name change"
    end
  end

  describe "edit name_change" do
    setup [:create_name_change]

    test "renders form for editing chosen name_change", %{conn: conn, name_change: name_change} do
      conn = get conn, name_change_path(conn, :edit, name_change)
      assert html_response(conn, 200) =~ "Edit Name change"
    end
  end

  describe "update name_change" do
    setup [:create_name_change]

    test "redirects when data is valid", %{conn: conn, name_change: name_change} do
      conn = put conn, name_change_path(conn, :update, name_change), name_change: @update_attrs
      assert redirected_to(conn) == name_change_path(conn, :show, name_change)

      conn = get conn, name_change_path(conn, :show, name_change)
      assert html_response(conn, 200) =~ "some updated from"
    end

    test "renders errors when data is invalid", %{conn: conn, name_change: name_change} do
      conn = put conn, name_change_path(conn, :update, name_change), name_change: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Name change"
    end
  end

  describe "delete name_change" do
    setup [:create_name_change]

    test "deletes chosen name_change", %{conn: conn, name_change: name_change} do
      conn = delete conn, name_change_path(conn, :delete, name_change)
      assert redirected_to(conn) == name_change_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, name_change_path(conn, :show, name_change)
      end
    end
  end

  defp create_name_change(_) do
    name_change = fixture(:name_change)
    {:ok, name_change: name_change}
  end
end
