defmodule Todo.ListServerTest do
  use ExUnit.Case, async: true

  alias Todo.ListServer

  setup do
    owner_id = UUID.uuid4(:default)
    {:ok, pid} = ListServer.start_link(owner_id)
    %{pid: pid}
  end

  test "start a list server process" do
    owner_id = UUID.uuid4(:default)
    {:ok, pid} = ListServer.start_link(owner_id)
    list = :sys.get_state(pid)

    assert list.owner_id === owner_id
  end

  test "get the todo list from the list server", %{pid: pid} do
    {:ok, list} = ListServer.get_list(pid)
    state = :sys.get_state(pid)

    assert list === state
  end

  test "get a todo item by id from the list server", %{pid: pid} do
    {:ok, %{id: id}} = ListServer.add_entry(pid, "Write a passing test!")

    {:ok, entry} = ListServer.get_entry(pid, id)

    state = :sys.get_state(pid)
    assert entry === state.entries[id]
  end

  test "add an entry to a todo list", %{pid: pid} do
    {:ok, %{id: id}} = ListServer.add_entry(pid, "Write a passing test!")

    %{entries: entries} = :sys.get_state(pid)
    assert Map.has_key?(entries, id)
  end

  test "update an entry in a todo list", %{pid: pid} do
    {:ok, entry} = ListServer.add_entry(pid, "Write a failing test!")
    to_update = %{description: "Write a passing test!"}

    {:ok, updated_entry} = ListServer.update_entry(pid, entry.id, to_update)

    {:ok, %{entries: entries}} = ListServer.get_list(pid)
    assert updated_entry.description === to_update.description
    assert entries[entry.id].description === to_update.description
  end

  test "gracefully handle unsuccessful update", %{pid: pid} do
    {:ok, %{id: id}} = ListServer.add_entry(pid, "Write a failing test!")
    to_update = %{
      status: "This is an invalid status",
      description: "This is a valid description"
    }

    {:error, _reason} = ListServer.update_entry(pid, id, to_update)
  end

  test "gracefully handle unsuccessful get entry request", %{pid: pid} do
    {:ok, _entry} = ListServer.add_entry(pid, "Write a failing test!")
    random_id = UUID.uuid4(:default)

    {:error, _reason} = ListServer.get_entry(pid, random_id)
  end

  test "gracefully handle unsuccessful add entry request", %{pid: pid} do
    {:error, _reason} = ListServer.add_entry(pid, :this_should_fail)
  end

  test "gracefully handle unsuccessful delete entry request", %{pid: pid} do
    random_id = UUID.uuid4(:default)
    {:error, _reason} = ListServer.delete_entry(pid, random_id)
  end

  test "delete an entry in a todo list", %{pid: pid} do
    {:ok, entry} = ListServer.add_entry(pid, "Write a failing test!")

    ListServer.delete_entry(pid, entry.id)

    {:ok, %{entries: entries}} = ListServer.get_list(pid)
    assert not Map.has_key?(entries, entry.id)
  end

  test "access server via list id", %{pid: pid} do
    {:ok, %{id: id}} = ListServer.get_list(pid)
    server = ListServer.via(id)

    assert GenServer.whereis(server) === pid
  end
end
