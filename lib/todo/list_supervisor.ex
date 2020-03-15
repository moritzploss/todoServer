defmodule Todo.ListSupervisor do
  use DynamicSupervisor

  alias Todo.ListServer

  defp pid_via_list_id(list_id) do
    list_id
    |> ListServer.via
    |> GenServer.whereis
  end

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_list(owner_id) do
    spec = %{
      id: ListServer,
      start: {ListServer, :start_link, [owner_id]},
      restart: :transient
    }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_list(list_id) do
    DynamicSupervisor.terminate_child(__MODULE__, pid_via_list_id(list_id))
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
