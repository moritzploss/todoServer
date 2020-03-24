defmodule TodoInterfaceWeb.ListController do
  use TodoInterfaceWeb, :controller

  alias Todo.{ListServer, ListManager, UserManager}

  defp get_or_create_list_manager(user_id) do
    case UserManager.list_supervisor_pid_via_user_id(user_id) do
      nil ->
        {:ok, manager_pid} = UserManager.start_list_manager(user_id)
        manager_pid
      manager_pid -> manager_pid
    end
  end

  def index(conn, %{"user_id" => user_id}) do
    lists = user_id
    |> get_or_create_list_manager
    |> ListManager.get_lists

    json(conn, %{lists: lists})
  end

  def show(conn, %{"id" => id, "user_id" => user_id}) do
    {:ok, list} = user_id
    |> get_or_create_list_manager
    |> ListManager.get_list(id)

    json(conn, list)
  end

  def create(conn, %{"user_id" => user_id}) do
    {:ok, pid} = user_id
    |> get_or_create_list_manager
    |> ListManager.start_list

    {:ok, list} = ListServer.get_list(pid)

    json(conn, list)
  end

  def delete(conn, %{"id" => id, "user_id" => user_id}) do
    :ok = user_id
    |> get_or_create_list_manager
    |> ListManager.stop_list(id)

    json(conn, %{})
  end
end
