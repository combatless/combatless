defmodule CombatlessWeb.NameChangeController do
  use CombatlessWeb, :controller

  alias Combatless.Accounts
  alias Combatless.Accounts.NameChange

  def request(conn, %{"from" => from, "to" => to}) do
    changeset = Accounts.change_name_change(%NameChange{from: from, to: to, is_valid: false})
    render(conn, "request.html", changeset: changeset)
  end

  def request(conn, params) do
    changeset = Accounts.change_name_change(%NameChange{})
    render(conn, "request.html", changeset: changeset)
  end

  def create_request(conn, %{"name_change" => name_change_params}) do
    name_change_params = Map.put(name_change_params, "is_valid", false)
    case Accounts.create_name_change(name_change_params) do
      {:ok, name_change} ->
        conn
        |> put_flash(:info, "Name change created successfully.")
        |> redirect(to: profile_path(conn, :show, name_change.from))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "request.html", changeset: changeset)
    end
  end
end
