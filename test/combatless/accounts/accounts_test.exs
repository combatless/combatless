defmodule Combatless.AccountsTest do
  use Combatless.DataCase

  alias Combatless.Accounts

  describe "accounts" do
    alias Combatless.Accounts.Account

    @valid_attrs %{is_abandoned: true, is_combatless: true, is_on_hiscores: true, name: "some name", old_name: "some old_name", settings: %{}}
    @update_attrs %{is_abandoned: false, is_combatless: false, is_on_hiscores: false, name: "some updated name", old_name: "some updated old_name", settings: %{}}
    @invalid_attrs %{is_abandoned: nil, is_combatless: nil, is_on_hiscores: nil, name: nil, old_name: nil, settings: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Accounts.create_account(@valid_attrs)
      assert account.is_abandoned == true
      assert account.is_combatless == true
      assert account.is_on_hiscores == true
      assert account.name == "some name"
      assert account.old_name == "some old_name"
      assert account.settings == %{}
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, account} = Accounts.update_account(account, @update_attrs)
      assert %Account{} = account
      assert account.is_abandoned == false
      assert account.is_combatless == false
      assert account.is_on_hiscores == false
      assert account.name == "some updated name"
      assert account.old_name == "some updated old_name"
      assert account.settings == %{}
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end
end
