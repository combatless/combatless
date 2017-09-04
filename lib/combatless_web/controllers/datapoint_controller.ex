defmodule CombatlessWeb.DatapointController do
  use CombatlessWeb, :controller

  alias Combatless.Datapoints
  alias Combatless.Datapoints.Datapoint

  def index(conn, _params) do
    datapoints = Datapoints.list_datapoints()
    render(conn, "index.html", datapoints: datapoints)
  end

  def new(conn, _params) do
    changeset = Datapoints.change_datapoint(%Datapoint{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"datapoint" => datapoint_params}) do
    case Datapoints.create_datapoint(datapoint_params) do
      {:ok, datapoint} ->
        conn
        |> put_flash(:info, "Datapoint created successfully.")
        |> redirect(to: datapoint_path(conn, :show, datapoint))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    datapoint = Datapoints.get_datapoint!(id)
    render(conn, "show.html", datapoint: datapoint)
  end

  def edit(conn, %{"id" => id}) do
    datapoint = Datapoints.get_datapoint!(id)
    changeset = Datapoints.change_datapoint(datapoint)
    render(conn, "edit.html", datapoint: datapoint, changeset: changeset)
  end

  def update(conn, %{"id" => id, "datapoint" => datapoint_params}) do
    datapoint = Datapoints.get_datapoint!(id)

    case Datapoints.update_datapoint(datapoint, datapoint_params) do
      {:ok, datapoint} ->
        conn
        |> put_flash(:info, "Datapoint updated successfully.")
        |> redirect(to: datapoint_path(conn, :show, datapoint))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", datapoint: datapoint, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    datapoint = Datapoints.get_datapoint!(id)
    {:ok, _datapoint} = Datapoints.delete_datapoint(datapoint)

    conn
    |> put_flash(:info, "Datapoint deleted successfully.")
    |> redirect(to: datapoint_path(conn, :index))
  end
end
