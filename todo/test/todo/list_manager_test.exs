defmodule Todo.ListManagerTest do
  use ExUnit.Case, async: false

  alias Todo.{ListManager, ListServer, UserManager}

  setup do
    on_exit(&UserManager.stop_list_managers/0)

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
    true = Process.alive?(list_pid)
    ListManager.stop_list(pid, list_pid)
    refute Process.alive?(list_pid)
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

    ListManager.stop_list(pid, list_pid1)
    refute Process.alive?(list_pid1)

    {:ok, %{id: id}} = ListServer.get_list(list_pid2)
    ListManager.stop_list(pid, id)
    refute Process.alive?(list_pid2)
  end

  test "restart crashed list servers with last good state", %{pid: pid} do
    {:ok, list_pid} = ListManager.start_list(pid)
    {:ok, %{id: list_id}} = ListServer.get_list(list_pid)
    {:ok, entry} = ListServer.add_entry(list_pid, "test")
    {:ok, _pid} = ListManager.start_list(pid)

    true = Process.exit(list_pid, :kaboom)

    Process.sleep(10) # give DynamicSupervisor some time to restart child
    pid_after_crash = ListManager.server_pid_via_list_id(list_id)

    assert {:ok, ^entry} = ListServer.get_entry(pid_after_crash, entry.id)
  end
end
