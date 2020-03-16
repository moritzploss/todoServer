defmodule Todo.EntryTest do
  use ExUnit.Case, async: true

  alias Todo.Entry

  test "create new entry" do
    {:ok, entry} = Entry.new("Write a passing test!")

    assert Map.has_key?(entry, :id)
    assert Map.has_key?(entry, :description)
    assert Map.has_key?(entry, :status)
    assert Map.has_key?(entry, :date)
  end

  test "gracefully handle invalid description on initialization" do
    {:error, _reason} = Entry.new(:this_should_fail)
  end

  test "update entry description" do
    {:ok, entry} = Entry.new("Write a failing test!")
    new_description = "Then make it pass!"
    {:ok, new_entry} = Entry.update(entry, %{description: new_description})

    assert new_entry.description === new_description
    assert Map.delete(new_entry, :description) === Map.delete(entry, :description)
  end

  test "update entry status" do
    {:ok, entry} = Entry.new("Write a passing test!")
    {:ok, closed_entry} = Entry.update(entry, %{status: :closed})

    assert closed_entry.status === :closed
    assert Map.delete(closed_entry, :status) === Map.delete(entry, :status)
  end

  test "don't update entry description with invalid value" do
    {:ok, entry} = Entry.new("Write a failing test!")
    {:error, _reason} = Entry.update(entry, %{description: :then_make_it_pass})
  end

  test "don't update entry status with invalid value" do
    {:ok, entry} = Entry.new("Write a passing test!")
    {:error, _reason} = Entry.update(entry, %{status: :unknown_value})
  end

  test "don't update non-updatable keys" do
    {:ok, entry} = Entry.new("Write a passing test!")
    {:error, _reason} = Entry.update(entry, %{unknown_field: :unknown_value})
  end

  test "serialize entry" do
    {:ok, entry} = Entry.new("Write a passing test!")
    %{id: _, date: _, description: _, status: _} = Entry.serialize!(entry)
  end
end
