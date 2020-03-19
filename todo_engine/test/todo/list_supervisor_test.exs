defmodule Todo.ListSupervisorTest do
  use ExUnit.Case, async: false

  alias Todo.{ListSupervisor, ListServer, UserSupervisor}

  setup do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserSupervisor.start_list_supervisor(user_id)
    {:ok, list_pid} = ListSupervisor.start_list(pid)
    %{pid: pid, list_pid: list_pid, user_id: user_id}
  end

  test "start new list server" do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserSupervisor.start_list_supervisor(user_id)
    {:ok, list_pid} = ListSupervisor.start_list(pid)

    assert Process.alive?(list_pid)
  end

  test "stop list server", %{pid: pid, list_pid: list_pid} do
    assert Process.alive?(list_pid)
    ListSupervisor.stop_list(pid, list_pid)
    assert not Process.alive?(list_pid)
  end

  test "start mulptiple list servers", %{pid: pid} do
    {:ok, pid1} = ListSupervisor.start_list(pid)
    {:ok, pid2} = ListSupervisor.start_list(pid)

    assert Process.alive?(pid1)
    assert Process.alive?(pid2)
  end

  test "stop list servers both via pid and list ID", %{pid: pid} do
    {:ok, list_pid1} = ListSupervisor.start_list(pid)
    {:ok, list_pid2} = ListSupervisor.start_list(pid)

    assert Process.alive?(list_pid1)
    assert Process.alive?(list_pid2)

    ListSupervisor.stop_list(pid, list_pid1)
    assert not Process.alive?(list_pid1)

    {:ok, %{id: id}} = ListServer.get_list(list_pid2)
    ListSupervisor.stop_list(pid, id)
    assert not Process.alive?(list_pid2)
  end

  test "restart crashed list servers", %{pid: pid} do
    Enum.map(DynamicSupervisor.which_children(pid),
      fn {_id, child_pid, _type, _modules} ->
        ListSupervisor.stop_list(pid, child_pid)
      end)

    count_workers = fn ->
      # IO.inspect DynamicSupervisor.which_children(pid)
      DynamicSupervisor.count_children(pid).workers
    end

    {:ok, list_pid} = ListSupervisor.start_list(pid)
    {:ok, %{id: list_id}} = ListServer.get_list(list_pid)
    assert count_workers.() === 1

    {:ok, _pid} = ListSupervisor.start_list(pid)
    assert count_workers.() === 2

    assert Process.alive?(list_pid)
    Process.exit(list_pid, :kaboom)
    assert not Process.alive?(list_pid)

    Process.sleep(10) # give DynamicSupervisor some time to restart child
    pid_after_crash = ListSupervisor.server_pid_via_list_id(list_id)
    assert pid_after_crash !== list_pid
    assert Process.alive?(pid_after_crash)
    assert count_workers.() === 2
  end
end
