defmodule Todo.List do
  alias Todo.{Entry, List}

  defstruct entries: %{}

  def new do
    %Todo.List{}
  end

  def add_entry(%List{} = todo_list, %Entry{} = entry) do
    new_entries = Map.put(todo_list.entries, entry.id, entry)
    {:ok, %Todo.List{todo_list | entries: new_entries}}
  end

  defguardp is_id(entry_id) when is_binary(entry_id)

  def get_entry(%List{} = todo_list, entry_id) when is_id(entry_id) do
    case Map.get(todo_list.entries, entry_id) do
      nil -> {:error, :no_entry_with_id}
      entry -> {:ok, entry}
    end
  end

  def update_entry(%List{} = todo_list, entry_id, %Entry{} = entry) when is_id(entry_id) do
    case Map.fetch(todo_list.entries, entry_id) do
      {:ok, _entry} -> {:ok, Map.put(todo_list, entry_id, entry)}
      :error -> {:error, :no_entry_with_id}
    end
  end

  def delete_entry(%List{} = todo_list, entry_id) when is_id(entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    {:ok, %Todo.List{todo_list | entries: new_entries}}
  end

  def serialize(%List{} = todo_list) do
    serialized_entries = for {id, entry} <- todo_list.entries, into: %{} do
      {id, Entry.serialize(entry)}
    end
    serialized_list = Map.from_struct(%{todo_list | entries: serialized_entries})
    {:ok, serialized_list}
  end
end
