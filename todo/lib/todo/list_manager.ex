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

  def stop_list(pid, list_pid) when is_pid(list_pid) do
    DynamicSupervisor.terminate_child(pid, list_pid)
  end

  def stop_list(pid, list_id) do
    stop_list(pid, server_pid_via_list_id(list_id))
  end

  def get_lists(pid) do
    pid
    |> DynamicSupervisor.which_children
    |> Enum.map(fn {_id, list_pid, _type, _modules} -> list_pid end)
    |> Enum.map(&ListServer.get_list(&1))
  end

  @impl true
  @spec init({:user_id, any}) :: {:ok, %{extra_arguments: [any], intensity: non_neg_integer, max_children: :infinity | non_neg_integer, period: pos_integer, strategy: :one_for_one}}
  def init({:user_id, user_id}) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [user_id])
  end
end
