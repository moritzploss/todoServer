defmodule Todo.UserManagerTest do
  use ExUnit.Case, async: false

  alias Todo.{UserManager, ListManager, ListServer}

  setup do
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
    :ok = UserManager.stop_list_manager(pid)
    assert not Process.alive?(pid)
  end

  test "stop list supervisor by user id", %{pid: pid, user_id: user_id} do
    assert Process.alive?(pid)
    :ok = UserManager.stop_list_manager(user_id)
    assert not Process.alive?(pid)
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

  # test "restart crashed list manager with last good state", %{pid: pid} do
  #   {:ok, list_pid} = ListManager.start_list(pid)
  #   {:ok, list} = ListServer.get_list(list_pid)
  #   {:ok, entry} = ListServer.add_entry(list_pid, "test")

  #   only_pids = fn children ->
  #     Enum.map(children, fn {_id, child_pid, _type, _modules} -> child_pid end)
  #   end

  #   child_pids_before = UserManager
  #   |> DynamicSupervisor.which_children
  #   |> only_pids.()

  #   Process.exit(pid, :kill)
  #   Process.sleep(10)

  #   child_pids_after = UserManager
  #   |> DynamicSupervisor.which_children
  #   |> only_pids.()

  #   [new_pid] = Enum.filter(child_pids_after, fn pid ->
  #     pid not in child_pids_before
  #   end)

  #   IO.inspect ListManager.get_lists(new_pid)
  # end
end
