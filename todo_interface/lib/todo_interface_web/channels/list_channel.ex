defmodule TodoInterfaceWeb.ListChannel do
  use TodoInterfaceWeb, :channel

  alias Todo.{ListServer, ListSupervisor, UserListServer}
  alias TodoInterfaceWeb.Presence

  defp list_id("list:" <> list_id) do
    list_id
  end

  def join("list:" <> list_id, %{}, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    user_id = "12345-test"
    pid =
      case ListSupervisor.pid_via_list_id(list_id(socket.topic)) do
        nil ->
          {:ok, pid} = ListSupervisor.start_list(user_id)
          pid
        pid -> pid
      end
    {:ok, list} = ListServer.get_list(pid)

    broadcast!(socket, "list", list)
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second))
    })
    {:noreply, socket}

  end
end
