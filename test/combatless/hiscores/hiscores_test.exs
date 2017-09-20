defmodule Combatless.HiscoresTest do
  use Combatless.DataCase

  alias Combatless.Hiscores

  describe "hiscores" do
    alias Combatless.Hiscores.Hiscore

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def hiscore_fixture(attrs \\ %{}) do
      {:ok, hiscore} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Hiscores.create_hiscore()

      hiscore
    end

    test "list_hiscores/0 returns all hiscores" do
      hiscore = hiscore_fixture()
      assert Hiscores.list_hiscores() == [hiscore]
    end

    test "get_hiscore!/1 returns the hiscore with given id" do
      hiscore = hiscore_fixture()
      assert Hiscores.get_hiscore!(hiscore.id) == hiscore
    end

    test "create_hiscore/1 with valid data creates a hiscore" do
      assert {:ok, %Hiscore{} = hiscore} = Hiscores.create_hiscore(@valid_attrs)
    end

    test "create_hiscore/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hiscores.create_hiscore(@invalid_attrs)
    end

    test "update_hiscore/2 with valid data updates the hiscore" do
      hiscore = hiscore_fixture()
      assert {:ok, hiscore} = Hiscores.update_hiscore(hiscore, @update_attrs)
      assert %Hiscore{} = hiscore
    end

    test "update_hiscore/2 with invalid data returns error changeset" do
      hiscore = hiscore_fixture()
      assert {:error, %Ecto.Changeset{}} = Hiscores.update_hiscore(hiscore, @invalid_attrs)
      assert hiscore == Hiscores.get_hiscore!(hiscore.id)
    end

    test "delete_hiscore/1 deletes the hiscore" do
      hiscore = hiscore_fixture()
      assert {:ok, %Hiscore{}} = Hiscores.delete_hiscore(hiscore)
      assert_raise Ecto.NoResultsError, fn -> Hiscores.get_hiscore!(hiscore.id) end
    end

    test "change_hiscore/1 returns a hiscore changeset" do
      hiscore = hiscore_fixture()
      assert %Ecto.Changeset{} = Hiscores.change_hiscore(hiscore)
    end
  end
end
