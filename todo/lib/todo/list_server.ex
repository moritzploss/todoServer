defmodule Todo.ListServer do
  use GenServer

  alias Todo.Entry
  alias Repo.UserRepo

  def via(id), do: {:via, Registry, {Registry.TodoLists, id}}

  # Client API

  def start_link(user_id, list_id, list_name \\ "list") do
    args = %{user_id: user_id, list_id: list_id, list_name: list_name}
    GenServer.start_link(__MODULE__, args, name: via(list_id))
  end

  def get_list(server_pid) do
    GenServer.call(server_pid, :get_list)
  end

  def rename_list(server_pid, name) do
    GenServer.call(server_pid, {:rename_list, name})
  end

  def get_entry(server_pid, entry_id) do
    GenServer.call(server_pid, {:get_entry, entry_id})
  end

  def which_entries(server_pid) do
    GenServer.call(server_pid, :which_entries)
  end

  def add_entry(server_pid, description) do
    GenServer.call(server_pid, {:add_entry, description})
  end

  def update_entry(server_pid, entry_id, to_update) do
    GenServer.call(server_pid, {:update_entry, entry_id, to_update})
  end

  def delete_entry(server_pid, entry_id) do
    GenServer.call(server_pid, {:delete_entry, entry_id})
  end

  # Helper

  defp save_list_state(list), do: :ets.insert(:list_state, {list.id, list})

  defp initialize_list(user_id, list_id, list_name) do
    {:ok, list} = Todo.List.new(user_id, list_id, list_name)
    save_list_state(list)
    UserRepo.add(user_id, list_id)
    list
  end

  # Callbacks

  @impl GenServer
  def init(%{user_id: user_id, list_id: list_id, list_name: list_name}) do
    case :ets.lookup(:list_state, list_id) do
      [] -> {:ok, initialize_list(user_id, list_id, list_name)}
      [{_key, list}] -> {:ok, list}
    end
  end

  @impl GenServer
  def handle_call(:get_list, _from, state) do
    {:reply, {:ok, state}, state}
  end

  @impl GenServer
  def handle_call({:rename_list, name}, _from, state) do
    renamed = Todo.List.rename(state, name)
    {:reply, {:ok, renamed}, renamed}
  end

  @impl GenServer
  def handle_call({:get_entry, entry_id}, _from, state) do
    case Todo.List.get_entry(state, entry_id) do
      {:ok, entry} -> {:reply, {:ok, entry}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call(:which_entries, _from, state) do
    {:reply, {:ok, state.entries}, state}
  end

  @impl GenServer
  def handle_call({:add_entry, description}, _from, state) do
    with {:ok, entry} <- Entry.new(description),
      {:ok, list} <- Todo.List.add_entry(state, entry)
    do
      save_list_state(list)
      {:reply, {:ok, entry}, list}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call({:update_entry, entry_id, to_update}, _from, state) do
    with {:ok, entry} <- Todo.List.get_entry(state, entry_id),
      {:ok, entry} <- Entry.update(entry, to_update),
      {:ok, list} <- Todo.List.update_entry(state, entry_id, entry)
    do
      save_list_state(list)
      {:reply, {:ok, entry}, list}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call({:delete_entry, entry_id}, _from, state) do
    case Todo.List.delete_entry(state, entry_id) do
      {:ok, list} ->
        save_list_state(list)
        {:reply, :ok, list}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end
end
