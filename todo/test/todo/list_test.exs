defmodule Todo.ListTest do
  use ExUnit.Case, async: true

  alias Todo.Entry

  setup do
    {:ok, list} = Todo.List.new(UUID.uuid4(:default), UUID.uuid4(:default))
    {:ok, entry} = Entry.new("Write more tests!")
    %{list: list, entry: entry}
  end

  test "create new list" do
    {:ok, list} = Todo.List.new(UUID.uuid4(:default), UUID.uuid4(:default))

    assert Map.has_key?(list, :id)
    assert Map.has_key?(list, :owner_id)
    assert Map.has_key?(list, :entries)
  end

  test "add entry to list", %{list: list, entry: entry} do
    {:ok, list_with_entry} = Todo.List.add_entry(list, entry)
    assert list_with_entry.entries[entry.id] === entry
  end

  test "get entry by ID", %{list: list, entry: entry} do
    {:ok, list_with_entry} = Todo.List.add_entry(list, entry)
    {:ok, entry_in_list} = Todo.List.get_entry(list_with_entry, entry.id)
    assert entry_in_list === entry
  end

  test "update entry in list", %{list: list, entry: entry} do
    {:ok, list_with_entry} = Todo.List.add_entry(list, entry)
    {:ok, new_entry} = Entry.update(entry, %{status: :closed})

    {:ok, list_updated} = Todo.List.update_entry(list_with_entry, entry.id, new_entry)
    {:ok, entry_in_list} = Todo.List.get_entry(list_updated, entry.id)

    assert entry_in_list === new_entry
  end

  test "delete entry from list", %{list: list, entry: entry} do
    {:ok, list_with_entry} = Todo.List.add_entry(list, entry)
    {:ok, list_without_entry} = Todo.List.delete_entry(list_with_entry, entry.id)
    {:error, :id_not_found} = Todo.List.get_entry(list_without_entry, entry.id)
  end
end
