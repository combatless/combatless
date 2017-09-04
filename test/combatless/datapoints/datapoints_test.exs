defmodule Combatless.DatapointsTest do
  use Combatless.DataCase

  alias Combatless.Datapoints

  describe "datapoints" do
    alias Combatless.Datapoints.Datapoint

    @valid_attrs %{ehp_version: 42, fetched_at: "some fetched_at", is_valid: true}
    @update_attrs %{ehp_version: 43, fetched_at: "some updated fetched_at", is_valid: false}
    @invalid_attrs %{ehp_version: nil, fetched_at: nil, is_valid: nil}

    def datapoint_fixture(attrs \\ %{}) do
      {:ok, datapoint} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Datapoints.create_datapoint()

      datapoint
    end

    test "list_datapoints/0 returns all datapoints" do
      datapoint = datapoint_fixture()
      assert Datapoints.list_datapoints() == [datapoint]
    end

    test "get_datapoint!/1 returns the datapoint with given id" do
      datapoint = datapoint_fixture()
      assert Datapoints.get_datapoint!(datapoint.id) == datapoint
    end

    test "create_datapoint/1 with valid data creates a datapoint" do
      assert {:ok, %Datapoint{} = datapoint} = Datapoints.create_datapoint(@valid_attrs)
      assert datapoint.ehp_version == 42
      assert datapoint.fetched_at == "some fetched_at"
      assert datapoint.is_valid == true
    end

    test "create_datapoint/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Datapoints.create_datapoint(@invalid_attrs)
    end

    test "update_datapoint/2 with valid data updates the datapoint" do
      datapoint = datapoint_fixture()
      assert {:ok, datapoint} = Datapoints.update_datapoint(datapoint, @update_attrs)
      assert %Datapoint{} = datapoint
      assert datapoint.ehp_version == 43
      assert datapoint.fetched_at == "some updated fetched_at"
      assert datapoint.is_valid == false
    end

    test "update_datapoint/2 with invalid data returns error changeset" do
      datapoint = datapoint_fixture()
      assert {:error, %Ecto.Changeset{}} = Datapoints.update_datapoint(datapoint, @invalid_attrs)
      assert datapoint == Datapoints.get_datapoint!(datapoint.id)
    end

    test "delete_datapoint/1 deletes the datapoint" do
      datapoint = datapoint_fixture()
      assert {:ok, %Datapoint{}} = Datapoints.delete_datapoint(datapoint)
      assert_raise Ecto.NoResultsError, fn -> Datapoints.get_datapoint!(datapoint.id) end
    end

    test "change_datapoint/1 returns a datapoint changeset" do
      datapoint = datapoint_fixture()
      assert %Ecto.Changeset{} = Datapoints.change_datapoint(datapoint)
    end
  end
end
