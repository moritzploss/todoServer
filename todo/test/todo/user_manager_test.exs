defmodule Todo.UserManagerTest do
  use ExUnit.Case, async: false

  alias Todo.UserManager

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
end
