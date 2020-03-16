defmodule Todo.ListSupervisorTest do
  use ExUnit.Case, async: false

  alias Todo.{ListSupervisor, ListServer}

  setup do
    owner_id = UUID.uuid4(:default)
    {:ok, pid} = ListSupervisor.start_list(owner_id)
    %{pid: pid, owner_id: owner_id}
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

  test "stop list servers both via pid and list ID", %{owner_id: owner_id}  do
    {:ok, pid} = ListSupervisor.start_list(owner_id)
    {:ok, pid2} = ListSupervisor.start_list(owner_id)

    assert Process.alive?(pid)
    assert Process.alive?(pid2)

    ListSupervisor.stop_list(pid)
    assert not Process.alive?(pid)

    {:ok, %{id: id}} = ListServer.get_list(pid2)
    ListSupervisor.stop_list(id)
    assert not Process.alive?(pid2)
  end

  test "restart crashed list servers", %{owner_id: owner_id} do
    Enum.map(DynamicSupervisor.which_children(ListSupervisor),
      fn {_id, pid, _type, _modules} ->
        ListSupervisor.stop_list(pid)
      end)

    count_workers = fn ->
      DynamicSupervisor.count_children(ListSupervisor).workers
    end

    {:ok, pid} = ListSupervisor.start_list(owner_id)
    {:ok, %{id: list_id}} = ListServer.get_list(pid)
    assert count_workers.() === 1

    {:ok, _pid} = ListSupervisor.start_list(owner_id)
    assert count_workers.() === 2

    assert Process.alive?(pid)
    Process.exit(pid, :kaboom)
    assert not Process.alive?(pid)

    Process.sleep(10) # give DynamicSupervisor some time to restart child
    pid_after_crash = ListSupervisor.pid_via_list_id(list_id)
    assert pid_after_crash !== pid
    assert Process.alive?(pid_after_crash)
    assert count_workers.() === 2
  end
end
