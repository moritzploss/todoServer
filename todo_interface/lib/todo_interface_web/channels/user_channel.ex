defmodule TodoInterfaceWeb.UserChannel do
  use TodoInterfaceWeb, :channel

  alias Todo.{ListManager, UserManager}

  defp get_or_create_list_manager(user_id) do
    case UserManager.list_supervisor_pid_via_user_id(user_id) do
      nil ->
        {:ok, manager_pid} = UserManager.start_list_manager(user_id)
        manager_pid
      manager_pid -> manager_pid
    end
  end

  def join("user:" <> user_id, %{}, socket) do
    send(self(), {:after_join, user_id})
    {:ok, socket}
  end

  def handle_info({:after_join, user_id}, socket) do
    lists = user_id
    |> get_or_create_list_manager
    |> ListManager.get_lists
    |> Enum.map(fn {:ok, list} -> list end)

    push(socket, "lists", %{lists: lists})
    {:noreply, socket}
  end
end
