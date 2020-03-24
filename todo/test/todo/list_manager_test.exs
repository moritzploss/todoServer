defmodule Todo.ListManagerTest do
  use ExUnit.Case, async: false

  alias Todo.{ListManager, ListServer, UserManager}

  setup do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserManager.start_list_manager(user_id)
    {:ok, list_pid} = ListManager.start_list(pid)
    %{pid: pid, list_pid: list_pid, user_id: user_id}
  end

  test "start new list server" do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserManager.start_list_manager(user_id)
    {:ok, list_pid} = ListManager.start_list(pid)

    assert Process.alive?(list_pid)
  end

  test "stop list server", %{pid: pid, list_pid: list_pid} do
    assert Process.alive?(list_pid)
    ListManager.stop_list(pid, list_pid)
    assert not Process.alive?(list_pid)
  end

  test "get list via list id", %{pid: pid, list_pid: list_pid} do
    {:ok, list1} = ListServer.get_list(list_pid)
    {:ok, list2} = ListManager.get_list(pid, list1.id)
    assert list1 === list2
  end

  test "start mulptiple list servers", %{pid: pid} do
    {:ok, pid1} = ListManager.start_list(pid)
    {:ok, pid2} = ListManager.start_list(pid)

    assert Process.alive?(pid1)
    assert Process.alive?(pid2)
  end

  test "stop list servers both via pid and list ID", %{pid: pid} do
    {:ok, list_pid1} = ListManager.start_list(pid)
    {:ok, list_pid2} = ListManager.start_list(pid)

    assert Process.alive?(list_pid1)
    assert Process.alive?(list_pid2)

    ListManager.stop_list(pid, list_pid1)
    assert not Process.alive?(list_pid1)

    {:ok, %{id: id}} = ListServer.get_list(list_pid2)
    ListManager.stop_list(pid, id)
    assert not Process.alive?(list_pid2)
  end

  test "restart crashed list servers", %{pid: pid} do
    Enum.map(DynamicSupervisor.which_children(pid),
      fn {_id, child_pid, _type, _modules} ->
        ListManager.stop_list(pid, child_pid)
      end)

    count_workers = fn ->
      # IO.inspect DynamicSupervisor.which_children(pid)
      DynamicSupervisor.count_children(pid).workers
    end

    {:ok, list_pid} = ListManager.start_list(pid)
    {:ok, %{id: list_id}} = ListServer.get_list(list_pid)
    assert count_workers.() === 1

    {:ok, _pid} = ListManager.start_list(pid)
    assert count_workers.() === 2

    assert Process.alive?(list_pid)
    Process.exit(list_pid, :kaboom)
    assert not Process.alive?(list_pid)

    Process.sleep(10) # give DynamicSupervisor some time to restart child
    pid_after_crash = ListManager.server_pid_via_list_id(list_id)
    assert pid_after_crash !== list_pid
    assert Process.alive?(pid_after_crash)
    assert count_workers.() === 2
  end
end
