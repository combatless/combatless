defmodule CombatlessWeb.DatapointControllerTest do
  use CombatlessWeb.ConnCase

  alias Combatless.Datapoints

  @create_attrs %{ehp_version: 42, fetched_at: "some fetched_at", is_valid: true}
  @update_attrs %{ehp_version: 43, fetched_at: "some updated fetched_at", is_valid: false}
  @invalid_attrs %{ehp_version: nil, fetched_at: nil, is_valid: nil}

  def fixture(:datapoint) do
    {:ok, datapoint} = Datapoints.create_datapoint(@create_attrs)
    datapoint
  end

  describe "index" do
    test "lists all datapoints", %{conn: conn} do
      conn = get conn, datapoint_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Datapoints"
    end
  end

  describe "new datapoint" do
    test "renders form", %{conn: conn} do
      conn = get conn, datapoint_path(conn, :new)
      assert html_response(conn, 200) =~ "New Datapoint"
    end
  end

  describe "create datapoint" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, datapoint_path(conn, :create), datapoint: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == datapoint_path(conn, :show, id)

      conn = get conn, datapoint_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Datapoint"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, datapoint_path(conn, :create), datapoint: @invalid_attrs
      assert html_response(conn, 200) =~ "New Datapoint"
    end
  end

  describe "edit datapoint" do
    setup [:create_datapoint]

    test "renders form for editing chosen datapoint", %{conn: conn, datapoint: datapoint} do
      conn = get conn, datapoint_path(conn, :edit, datapoint)
      assert html_response(conn, 200) =~ "Edit Datapoint"
    end
  end

  describe "update datapoint" do
    setup [:create_datapoint]

    test "redirects when data is valid", %{conn: conn, datapoint: datapoint} do
      conn = put conn, datapoint_path(conn, :update, datapoint), datapoint: @update_attrs
      assert redirected_to(conn) == datapoint_path(conn, :show, datapoint)

      conn = get conn, datapoint_path(conn, :show, datapoint)
      assert html_response(conn, 200) =~ "some updated fetched_at"
    end

    test "renders errors when data is invalid", %{conn: conn, datapoint: datapoint} do
      conn = put conn, datapoint_path(conn, :update, datapoint), datapoint: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Datapoint"
    end
  end

  describe "delete datapoint" do
    setup [:create_datapoint]

    test "deletes chosen datapoint", %{conn: conn, datapoint: datapoint} do
      conn = delete conn, datapoint_path(conn, :delete, datapoint)
      assert redirected_to(conn) == datapoint_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, datapoint_path(conn, :show, datapoint)
      end
    end
  end

  defp create_datapoint(_) do
    datapoint = fixture(:datapoint)
    {:ok, datapoint: datapoint}
  end
end
