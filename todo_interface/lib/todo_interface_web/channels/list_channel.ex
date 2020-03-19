defmodule TodoInterfaceWeb.ListChannel do
  use TodoInterfaceWeb, :channel

  alias Todo.{ListServer, ListManager, UserManager}
  alias TodoInterfaceWeb.Presence

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
        {:ok, manager_pid} = UserManager.start_list_supervisor(user_id)
        manager_pid
      manager_pid -> manager_pid
    end
  end

  defp get_list_server(list_id, user_id) do
    user_id
    |> get_or_create_list_manager
    |> get_or_create_list_server(list_id)
  end

  def join("list:", %{}, socket) do
    send(self(), {:after_join, Ecto.UUID})
    {:ok, socket}
  end

  def join("list:" <> list_id, %{}, socket) do
    send(self(), {:after_join, list_id})
    {:ok, socket}
  end

  def handle_info({:after_join, list_id}, socket) do
    user_id = "12345-test"

    {:ok, list} = list_id
    |> get_list_server(user_id)
    |> ListServer.get_list

    broadcast!(socket, "list", list)
    {:noreply, socket}
  end
end
