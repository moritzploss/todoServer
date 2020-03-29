defmodule Todo.UserManagerTest do
  use ExUnit.Case, async: false

  alias Todo.{ListManager, ListServer, UserManager}

  setup do
    on_exit(&UserManager.stop_list_managers/0)

    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserManager.start_list_manager(user_id)
    %{pid: pid, user_id: user_id}
  end

  test "start new list supervisor" do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserManager.start_list_manager(user_id)

    assert Process.alive?(pid)
  end

  test "stop list supervisor by pid", %{pid: pid} do
    assert Process.alive?(pid)
    assert :ok = UserManager.stop_list_manager(pid)
  end

  test "stop list supervisor by user id", %{pid: pid, user_id: user_id} do
    assert Process.alive?(pid)
    assert :ok = UserManager.stop_list_manager(user_id)
  end

  test "get or create list supervisor by user id" do
    user_id = UUID.uuid4(:default)
    {:ok, pid_create} = UserManager.get_or_create_list_manager(user_id)
    {:ok, pid_get} = UserManager.get_or_create_list_manager(user_id)

    assert pid_create === pid_get
  end

  test "gracefully handle stop request with non-existing user id" do
    {:error, _reason} = UserManager.stop_list_manager(UUID.uuid4(:default))
  end

  test "restart crashed list manager" do
    {:ok, manager_pid} = UserManager.start_list_manager(UUID.uuid4(:default))
    child_count = length(DynamicSupervisor.which_children(UserManager))
    assert Process.alive?(manager_pid)

    Process.exit(manager_pid, :kill)

    assert not Process.alive?(manager_pid)
    assert child_count === length(DynamicSupervisor.which_children(UserManager))
  end

  test "keep track of all users", %{user_id: user_id} do
    assert [^user_id] = UserManager.which_users()
  end

  test "restart crashed list manager with last good state", %{pid: pid} do
    {:ok, _entry} = pid
     |> ListManager.start_list
     |> elem(1)
     |> ListServer.add_entry("test")

    lists_before_crash = ListManager.get_lists(pid)

    only_pids = fn children ->
      Enum.map(children, fn {_, pid, _, _} -> pid end)
    end

    child_pids_before_crash = UserManager
      |> DynamicSupervisor.which_children
      |> only_pids.()

    Process.exit(pid, :kill)
    Process.sleep(10)

    lists_after_crash = UserManager
      |> DynamicSupervisor.which_children
      |> only_pids.()
      |> Enum.filter(fn pid -> pid not in child_pids_before_crash end)
      |> Enum.at(0)
      |> ListManager.get_lists

    assert lists_before_crash === lists_after_crash
  end
end
