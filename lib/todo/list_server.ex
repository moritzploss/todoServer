defmodule Todo.ListServer do
  use GenServer

  alias Todo.{Entry, List}

  def via(id) do
    {:via, Registry, {Registry.TodoLists, id}}
  end

  # Client API

  def start_link(owner_id) do
    args = %{owner_id: owner_id, list_id: UUID.uuid4(:default)}
    GenServer.start(__MODULE__, args, name: via(args.list_id))
  end

  def get_list(server_pid) do
    GenServer.call(server_pid, :get_list)
  end

  def get_entry(server_pid, entry_id) do
    GenServer.call(server_pid, {:get_entry, entry_id})
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

  # Callbacks

  @impl true
  def init(%{owner_id: owner_id, list_id: list_id}) do
    {:ok, list} = List.new(owner_id, list_id)
    {:ok, list}
  end

  @impl true
  def handle_call(:get_list, _from, state) do
    {:reply, {:ok, state}, state}
  end

  @impl true
  def handle_call({:get_entry, entry_id}, _from, state) do
    case List.get_entry(state, entry_id) do
      {:ok, entry} -> {:reply, {:ok, entry}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:add_entry, description}, _from, state) do
    with {:ok, entry} <- Entry.new(description),
      {:ok, list} <- List.add_entry(state, entry)
    do
      {:reply, {:ok, entry}, list}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:update_entry, entry_id, to_update}, _from, state) do
    with {:ok, entry} <- List.get_entry(state, entry_id),
      {:ok, entry} <- Entry.update(entry, to_update),
      {:ok, list} <- List.update_entry(state, entry_id, entry)
    do
      {:reply, {:ok, entry}, list}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:delete_entry, entry_id}, _from, state) do
    case List.delete_entry(state, entry_id) do
      {:ok, list} -> {:reply, :ok, list}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end
end
