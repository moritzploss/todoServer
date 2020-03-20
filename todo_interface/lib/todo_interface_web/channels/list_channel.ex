defmodule TodoInterfaceWeb.ListChannel do
  use TodoInterfaceWeb, :channel

  alias Todo.{ListServer, ListManager, UserManager}

  defp get_or_create_list_server(manager_pid, list_id) do
    case ListManager.server_pid_via_list_id(list_id) do
      nil ->
        {:ok, server_pid} = ListManager.start_list(manager_pid)
        server_pid
      server_pid -> server_pid
    end
  end

  defp get_or_create_list_manager(user_id) do
    case UserManager.list_supervisor_pid_via_user_id(user_id) do
      nil ->
        {:ok, manager_pid} = UserManager.start_list_manager(user_id)
        manager_pid
      manager_pid -> manager_pid
    end
  end

  def join("list:", %{"user_id" => user_id}, socket) do
    send(self(), {:after_join, user_id})
    {:ok, socket}
  end

  def handle_info({:after_join, user_id}, socket) do
    {:ok, pid} = user_id
    |> get_or_create_list_manager
    |> ListManager.start_list

    {:ok, list} = ListServer.get_list(pid)

    broadcast!(socket, "list", %{list: list})
    {:noreply, socket}
  end
end
