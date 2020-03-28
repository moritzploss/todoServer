defmodule TodoInterfaceWeb.EntryController do
  use TodoInterfaceWeb, :controller

  action_fallback TodoInterfaceWeb.ApiFallbackController

  alias Todo.{ListManager, ListServer}

  defp list_server(list_id) when is_binary(list_id) do
    case ListManager.server_pid_via_list_id(list_id) do
      nil -> {:error, :not_found}
      pid -> {:ok, pid}
    end
  end

  def index(conn, %{"list_id" => list_id}) do
    with {:ok, server_pid} <- list_server(list_id),
      {:ok, entries} <- ListServer.which_entries(server_pid)
    do
      json(conn, %{entries: entries})
    end
  end

  def show(conn, %{"id" => id, "list_id" => list_id}) do
    with {:ok, server_pid} <- list_server(list_id),
      {:ok, entry} <- ListServer.get_entry(server_pid, id)
    do
      json(conn, entry)
    end
  end

  def create(conn,  %{"list_id" => list_id, "description" => description}) do
    with {:ok, server_pid} <- list_server(list_id),
      {:ok, entry} <- ListServer.add_entry(server_pid, description)
    do
      json(conn, entry)
    end
  end

  defp reduce_to_valid(params, valid_params \\ %{})

  defp reduce_to_valid(%{"description" => description} = params, valid_params) do
    reduce_to_valid(
      Map.delete(params, "description"),
      Map.put(valid_params, :description, description)
    )
  end

  defp reduce_to_valid(%{"status" => status} = params, valid_params) do
    reduce_to_valid(
      Map.delete(params, "status"),
      Map.put(valid_params, :status, String.to_existing_atom(status))
    )
  end

  defp reduce_to_valid(_params, valid_params) do
    {:ok, valid_params}
  end

  def update(conn, %{"id" => id, "list_id" => list_id} = params) do
    with {:ok, server_pid} <- list_server(list_id),
      {:ok, valid_params} <- reduce_to_valid(params),
      {:ok, entry} <- ListServer.update_entry(server_pid, id, valid_params)
    do
      json(conn, entry)
    end
  end

  def delete(conn, %{"id" => id, "list_id" => list_id}) do
    with {:ok, server_pid} <- list_server(list_id),
      :ok <- ListServer.delete_entry(server_pid, id)
    do
      json(conn, %{})
    end
  end
end
