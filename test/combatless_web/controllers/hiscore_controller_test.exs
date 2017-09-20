defmodule CombatlessWeb.HiscoreControllerTest do
  use CombatlessWeb.ConnCase

  alias Combatless.Hiscores

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:hiscore) do
    {:ok, hiscore} = Hiscores.create_hiscore(@create_attrs)
    hiscore
  end

  describe "index" do
    test "lists all hiscores", %{conn: conn} do
      conn = get conn, hiscore_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Hiscores"
    end
  end

  describe "new hiscore" do
    test "renders form", %{conn: conn} do
      conn = get conn, hiscore_path(conn, :new)
      assert html_response(conn, 200) =~ "New Hiscore"
    end
  end

  describe "create hiscore" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, hiscore_path(conn, :create), hiscore: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == hiscore_path(conn, :show, id)

      conn = get conn, hiscore_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Hiscore"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, hiscore_path(conn, :create), hiscore: @invalid_attrs
      assert html_response(conn, 200) =~ "New Hiscore"
    end
  end

  describe "edit hiscore" do
    setup [:create_hiscore]

    test "renders form for editing chosen hiscore", %{conn: conn, hiscore: hiscore} do
      conn = get conn, hiscore_path(conn, :edit, hiscore)
      assert html_response(conn, 200) =~ "Edit Hiscore"
    end
  end

  describe "update hiscore" do
    setup [:create_hiscore]

    test "redirects when data is valid", %{conn: conn, hiscore: hiscore} do
      conn = put conn, hiscore_path(conn, :update, hiscore), hiscore: @update_attrs
      assert redirected_to(conn) == hiscore_path(conn, :show, hiscore)

      conn = get conn, hiscore_path(conn, :show, hiscore)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, hiscore: hiscore} do
      conn = put conn, hiscore_path(conn, :update, hiscore), hiscore: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Hiscore"
    end
  end

  describe "delete hiscore" do
    setup [:create_hiscore]

    test "deletes chosen hiscore", %{conn: conn, hiscore: hiscore} do
      conn = delete conn, hiscore_path(conn, :delete, hiscore)
      assert redirected_to(conn) == hiscore_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, hiscore_path(conn, :show, hiscore)
      end
    end
  end

  defp create_hiscore(_) do
    hiscore = fixture(:hiscore)
    {:ok, hiscore: hiscore}
  end
end
