defmodule Todo.ListManager do
  use DynamicSupervisor

  alias Todo.ListServer
  alias Repo.{ListRepo, UserRepo}

  # init

  def start_link(user_id) do
    {:ok, pid} = DynamicSupervisor.start_link(
      __MODULE__,
      {:user_id, user_id},
      name: via(user_id)
    )
    :ok = recover_children(pid, user_id)
    {:ok, pid}
  end

  @impl DynamicSupervisor
  def init({:user_id, user_id}) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [user_id])
  end

  # init children

  defp start_list_server(pid, list_id, name \\ "list") do
    spec = %{
      id: ListServer,
      start: {ListServer, :start_link, [list_id, name]},
      restart: :transient,
    }
    DynamicSupervisor.start_child(pid, spec)
  end

  defp recover_children(pid, user_id) do
    user_id
      |> UserRepo.lookup
      |> elem(1)
      |> Enum.each(fn list_id -> start_list_server(pid, list_id) end)
  end

  # client API

  def via(user_id), do: {:via, Registry, {Registry.TodoUsers, user_id}}

  def server_pid_via_list_id(list_id) do
    list_id
      |> ListServer.via
      |> GenServer.whereis
  end

  def start_list(pid, name \\ "list") do
    start_list_server(pid, UUID.uuid4(:default), name)
  end

  def stop_list(pid, list_pid) when is_pid(pid) and is_pid(list_pid) do
    {:ok, %{user_id: user_id, id: id}} = ListServer.get_list(list_pid)
    :ok = UserRepo.delete(user_id, id)
    :ok = ListRepo.drop(id)
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
      |> Enum.map(fn {_id, pid, _type, _modules} -> pid end)
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
end
