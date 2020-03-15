defmodule Todo.ListSupervisorTest do
  use ExUnit.Case, async: true

  alias Todo.{ListSupervisor, ListServer}

  setup do
    owner_id = UUID.uuid4(:default)
    {:ok, pid} = ListSupervisor.start_list(owner_id)
    %{pid: pid}
  end

  test "start new list server" do
    owner_id = UUID.uuid4(:default)
    {:ok, pid} = ListSupervisor.start_list(owner_id)

    assert Process.alive?(pid)
  end

  test "stop list server", %{pid: pid} do
    assert Process.alive?(pid)

    {:ok, %{id: id}} = ListServer.get_list(pid)
    ListSupervisor.stop_list(id)

    assert not Process.alive?(pid)
  end

  test "start mulptiple list servers" do
    owner_id1 = UUID.uuid4(:default)
    {:ok, pid1} = ListSupervisor.start_list(owner_id1)

    owner_id2 = UUID.uuid4(:default)
    {:ok, pid2} = ListSupervisor.start_list(owner_id2)

    assert Process.alive?(pid1)
    assert Process.alive?(pid2)
  end

  test "restart crashed list server with last good state", %{pid: pid} do
    # TODO: this doesn't work as expected

    {:ok, %{id: id}} = ListServer.get_list(pid)

    IO.inspect Process.exit(pid, :kill)
    IO.inspect Process.alive?(pid)

    new_pid = ListSupervisor.pid_via_list_id(id)
    IO.inspect new_pid
  end
end
