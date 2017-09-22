defmodule CombatlessWeb.ProfileController do
  use CombatlessWeb, :controller

  alias Combatless.Accounts
  alias Combatless.Accounts.Account

  def index(conn, %{"name" => name}) do
    username = Accounts.format_account_name(name)
    redirect(conn, to: profile_path(conn, :show, username))
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end


  def create(conn, %{"name" => name}) do
    with :ok <- Accounts.check_conflicting_accounts(name),
         {:ok, %Account{} = account} <- Accounts.create_account(%{name: name}),
         {:ok, _datapoint} <- Accounts.create_account_datapoint(account),
         {:ok, %Account{} = account} <- Accounts.activate_account(account) do
      conn
      |> put_flash(:info, "Account created successfully.")
      |> redirect(to: profile_path(conn, :show, account.name))
    else
      error -> handle_update_errors(conn, name, error)
    end
  end

  def update(conn, %{"name" => name}) do
    name
    |> Accounts.format_account_name()
    |> Accounts.get_active_account()
    |> case do
         nil -> redirect(conn, to: profile_path(conn, :show, name))
         %Account{} = account ->
           with {:ok, _datapoint} <- Accounts.create_account_datapoint(account) do
             redirect(conn, to: profile_path(conn, :show, account.name))
           else
             error -> handle_update_errors(conn, name, error)
           end
       end
  end

  def show(conn, %{"name" => name, "period" => "day"}), do: show(conn, period: :day, name: name)
  def show(conn, %{"name" => name, "period" => "week"}), do: show(conn, period: :week, name: name)
  def show(conn, %{"name" => name, "period" => "month"}), do: show(conn, period: :month, name: name)
  def show(conn, %{"name" => name, "period" => "year"}), do: show(conn, period: :year, name: name)
  def show(conn, %{"name" => name, "period" => "all"}), do: show(conn, period: :all, name: name)
  def show(conn, %{"name" => name}), do: show(conn, period: :week, name: name)
  def show(conn, opts) do
    opts[:name]
    |> Accounts.format_account_name()
    |> Accounts.get_active_account()
    |> case do
         nil ->
           new(conn, opts[:name])
         %Account{} = account ->
           profile = Accounts.get_account_profile(account, opts[:period])
           render(conn, "show.html", profile: profile)
       end
  end

  def new(conn, name) do
    render(conn, "new.html", changeset: Accounts.new_account_changeset(name))
  end

  def handle_update_errors(conn, name, error) do
    case error do
      {:error, :active_account_exists} ->
        conn
        |> put_flash(:error, "No need to create the account, this account already exists.")
        |> redirect(to: profile_path(conn, :show, Accounts.format_account_name(name)))
      {:error, :cooldown_active} ->
        conn
        |> put_flash(:error, "Updating is still on a 30 second cooldown.")
        |> redirect(to: profile_path(conn, :show, Accounts.format_account_name(name)))
      {:error, :unknown_hiscores_format} ->
        conn
        |> put_flash(:error, "Unknown hiscores format retrieved from Jagex's API.")
        |> redirect(to: profile_path(conn, :show, Accounts.format_account_name(name)))
      {:error, :not_combatless} ->
        account = Accounts.get_active_account(name)
        if account do
          Accounts.update_account(account, %{is_combatless: false, is_on_hiscores: true, is_abandoned: false})
        end
        conn
        |> put_flash(:error, "lmao you're not even level 3")
        |> redirect(to: profile_path(conn, :show, Accounts.format_account_name(name)))
      {:error, :username_does_not_exist} ->
        account = Accounts.get_active_account(name)
        if account do
          Accounts.update_account(account, %{is_combatless: false, is_on_hiscores: false, is_abandoned: true})
        end
        conn
        |> put_flash(:error, "Username does not exist on Jagex's hiscores.")
        |> redirect(to: profile_path(conn, :show, Accounts.format_account_name(name)))
      {:error, _} ->
        conn
        |> put_flash(:error, "Unknown error occured while updating user.  Contact bitwise if this occurs often.")
        |> redirect(to: profile_path(conn, :show, Accounts.format_account_name(name)))
    end
  end
end
