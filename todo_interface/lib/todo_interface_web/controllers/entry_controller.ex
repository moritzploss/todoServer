defmodule TodoInterfaceWeb.EntryController do
  use TodoInterfaceWeb, :controller

  action_fallback TodoInterfaceWeb.ApiFallbackController

  alias Todo.{ListManager, ListServer, UserManager}

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

  def create(conn,  %{"list_id" => list_id, "description" => description}) do
    with {:ok, server_pid} <- list_server(list_id),
      {:ok, entry} <- ListServer.add_entry(server_pid, description)
    do
      json(conn, entry)
    end
  end

  def show(conn, %{"id" => id, "list_id" => list_id}) do
    with {:ok, server_pid} <- list_server(list_id),
      {:ok, entry} <- ListServer.get_entry(server_pid, id)
    do
      json(conn, entry)
    end
  end

  defp as_safe_params(%{"description" => description} = params, safe_params \\ %{}) do
    as_safe_params(
      Map.delete(params, "description"),
      Map.put(safe_params, :description, description)
    )
  end

  defp as_safe_params(%{"status" => status} = params, safe_params) do
    as_safe_params(
      Map.delete(params, "status"),
      Map.put(safe_params, :status, String.to_existing_atom(status))
    )
  end

  defp as_safe_params(params, safe_params) do
    {:ok, safe_params}
  end

  def update(conn, %{"id" => id, "list_id" => list_id} = params) do
    with {:ok, server_pid} <- list_server(list_id),
      {:ok, safe_params} <- as_safe_params(params),
      {:ok, entry} <- ListServer.update_entry(server_pid, id, safe_params)
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
