defmodule Todo.EntryTest do
  use ExUnit.Case, async: true

  alias Todo.Entry

  test "update entry description" do
    {:ok, entry} = Entry.new("Write a failing test!")
    new_description = "Then make it pass!"
    {:ok, new_entry} = Entry.update(entry, :description, new_description)

    assert new_entry.description === new_description
    assert Map.delete(new_entry, :description) === Map.delete(entry, :description)
  end

  test "update entry status" do
    {:ok, entry} = Entry.new("Write a passing test!")
    {:ok, closed_entry} = Entry.update(entry, :status, :closed)

    assert closed_entry.status === :closed
    assert Map.delete(closed_entry, :status) === Map.delete(entry, :status)
  end

  test "serialize entry" do
    {:ok, entry} = Entry.new("Write a passing test!")
    {:ok, %{id: _, date: _, description: _, status: _}} = Entry.serialize(entry)
  end
end
