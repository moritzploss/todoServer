defmodule Todo.ListManager do
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
    DynamicSupervisor.start_link(
      __MODULE__,
      {:user_id, user_id},
      name: via(user_id)
    )
  end

  def start_list(pid) do
    spec = %{
      id: ListServer,
      start: {ListServer, :start_link, [UUID.uuid4(:default)]},
      restart: :transient,
    }
    DynamicSupervisor.start_child(pid, spec)
  end

  def stop_list(pid, list_pid) when is_pid(pid) and is_pid(list_pid) do
    DynamicSupervisor.terminate_child(pid, list_pid)
  end

  def stop_list(pid, list_id) when is_pid(pid) and is_binary(list_id) do
    case server_pid_via_list_id(list_id) do
      nil -> {:error, :not_found}
      server_pid -> stop_list(pid, server_pid)
    end
  end

  def get_lists(pid) do
    pid
      |> DynamicSupervisor.which_children
      |> Enum.map(fn {_id, list_pid, _type, _modules} -> list_pid end)
      |> Enum.map(&ListServer.get_list(&1))
      |> Enum.map(fn {:ok, list} -> list end)
  end

  def get_list(pid, list_id) do
    lists = get_lists(pid)
    case Enum.find(lists, nil, fn list -> list.id === list_id end) do
      nil -> {:error, :not_found}
      list -> {:ok, list}
    end
  end

  @impl DynamicSupervisor
  def init({:user_id, user_id}) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [user_id]
    )
  end
end
