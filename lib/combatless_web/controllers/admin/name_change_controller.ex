defmodule CombatlessWeb.Admin.NameChangeController do
  use CombatlessWeb, :controller

  alias Combatless.Accounts
  alias Combatless.Accounts.NameChange

  def index(conn, _params) do
    name_changes = Accounts.list_name_changes()
    render(conn, "index.html", name_changes: name_changes)
  end

  def new(conn, _params) do
    changeset = Accounts.change_name_change(%NameChange{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"name_change" => name_change_params}) do
    name_change_params = Map.put(name_change_params, "is_valid", false)
    case Accounts.create_name_change(name_change_params) do
      {:ok, name_change} ->
        conn
        |> put_flash(:info, "Name change created successfully.  Still needs to be approved.")
        |> redirect(to: mod_name_change_path(conn, :show, name_change))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    name_change = Accounts.get_name_change!(id)
    render(conn, "show.html", name_change: name_change)
  end

  def edit(conn, %{"id" => id}) do
    name_change = Accounts.get_name_change!(id)
    changeset = Accounts.change_name_change(name_change)
    render(conn, "edit.html", name_change: name_change, changeset: changeset)
  end

  def update(conn, %{"id" => id, "name_change" => name_change_params}) do
    name_change = Accounts.get_name_change!(id)

    case Accounts.update_name_change(name_change, name_change_params) do
      {:ok, name_change} ->
        conn
        |> put_flash(:info, "Name change updated successfully.")
        |> redirect(to: mod_name_change_path(conn, :show, name_change))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", name_change: name_change, changeset: changeset)
    end
  end
end
