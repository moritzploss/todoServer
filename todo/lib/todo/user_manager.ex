defmodule Todo.UserManager do
  use DynamicSupervisor

  alias Todo.ListManager

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def list_supervisor_pid_via_user_id(user_id) when is_binary(user_id) do
    user_id
    |> ListManager.via
    |> GenServer.whereis
  end

  def start_list_manager(user_id) when is_binary(user_id) do
    spec = %{
      id: ListManager,
      start: {ListManager, :start_link, [user_id]},
      restart: :transient,
    }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def get_or_create_list_manager(user_id) when is_binary(user_id) do
    case list_supervisor_pid_via_user_id(user_id) do
      nil -> start_list_manager(user_id)
      pid -> {:ok, pid}
    end
  end

  def which_users do
    __MODULE__
    |> DynamicSupervisor.which_children
    |> Enum.map(fn {_id, list_manager_pid, _type, _modules} ->
        Registry.keys(Registry.TodoUsers, list_manager_pid)
      end)
    |> List.flatten()
  end

  def stop_list_manager(supervisor_pid) when is_pid(supervisor_pid) do
    :ok = Registry.unregister(Registry.TodoUsers, supervisor_pid)
    DynamicSupervisor.terminate_child(__MODULE__, supervisor_pid)
  end

  def stop_list_manager(user_id) when is_binary(user_id) do
    case list_supervisor_pid_via_user_id(user_id) do
      nil -> {:error, :not_found}
      pid -> stop_list_manager(pid)
    end
  end

  def stop_list_managers do
    Enum.each(which_users(), &stop_list_manager(&1))
  end

  @impl DynamicSupervisor
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
