defmodule Todo.ListSupervisor do
  use DynamicSupervisor

  alias Todo.ListServer

  def via(user_id) do
    {:via, Registry, {Registry.TodoUsers, user_id}}
  end

  def server_pid_via_list_id(list_id) do
    list_id
    |> ListServer.via
    |> GenServer.whereis
  end

  def start_link(user_id) do
    DynamicSupervisor.start_link(__MODULE__, {:user_id, user_id}, name: via(user_id))
  end

  def start_list(pid) do
    spec = %{
      id: ListServer,
      start: {ListServer, :start_link, [UUID.uuid4(:default)]},
      restart: :transient,
    }
    DynamicSupervisor.start_child(pid, spec)
  end

  def stop_list(pid, list_pid) when is_pid(list_pid) do
    DynamicSupervisor.terminate_child(pid, list_pid)
  end

  def stop_list(pid, list_id) do
    stop_list(pid, server_pid_via_list_id(list_id))
  end

  @impl true
  def init({:user_id, user_id}) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [user_id])
  end
end
