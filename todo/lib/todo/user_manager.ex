defmodule Todo.UserManager do
  use DynamicSupervisor

  alias Todo.ListManager

  def list_supervisor_pid_via_user_id(user_id) do
    user_id
    |> ListManager.via
    |> GenServer.whereis
  end

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_list_manager(user_id) do
    spec = %{
      id: ListManager,
      start: {ListManager, :start_link, [user_id]},
      restart: :transient,
    }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_list_manager(supervisor_pid) when is_pid(supervisor_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, supervisor_pid)
  end

  def stop_list_manager(user_id) when is_binary(user_id) do
    case list_supervisor_pid_via_user_id(user_id) do
      nil -> {:error, :not_found}
      pid -> stop_list_manager(pid)
    end
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
