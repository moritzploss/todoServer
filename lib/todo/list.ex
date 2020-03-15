defmodule Todo.List do
  alias Todo.{Entry, List}

  defstruct [:entries, :id, :owner_id]

  @id_not_found_error {:error, :id_not_found}

  def new(owner_id, list_id) when is_binary(owner_id) do
    {:ok, %Todo.List{
      entries: %{},
      id: list_id,
      owner_id: owner_id,
    }}
  end

  def get_entry(%List{} = todo_list, entry_id) when is_binary(entry_id) do
    case Map.get(todo_list.entries, entry_id, nil) do
      nil -> @id_not_found_error
      entry -> {:ok, entry}
    end
  end

  def add_entry(%List{} = todo_list, %Entry{} = entry) do
    entries = Map.put(todo_list.entries, entry.id, entry)
    {:ok, %List{todo_list | entries: entries}}
  end

  def update_entry(%List{} = todo_list, entry_id, %Entry{} = entry) when is_binary(entry_id) do
    case Map.fetch(todo_list.entries, entry_id) do
      {:ok, _entry} -> {:ok, Map.put(todo_list, entry_id, entry)}
      :error -> @id_not_found_error
    end
  end

  def delete_entry(%List{} = todo_list, entry_id) when is_binary(entry_id) do
    case Map.has_key?(todo_list.entries, entry_id) do
      true ->
        entries = Map.delete(todo_list.entries, entry_id)
        {:ok, %List{todo_list | entries: entries}}
      false -> @id_not_found_error
    end
  end

  def serialize(%List{} = todo_list) do
    serialized_entries = for {id, entry} <- todo_list.entries, into: %{} do
      {id, Entry.serialize!(entry)}
    end
    serialized_list = Map.from_struct(%{todo_list | entries: serialized_entries})
    {:ok, serialized_list}
  end
end
