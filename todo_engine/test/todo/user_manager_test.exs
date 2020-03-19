defmodule Todo.UserManagerTest do
  use ExUnit.Case, async: false

  alias Todo.UserManager

  setup do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserManager.start_list_supervisor(user_id)
    %{pid: pid, user_id: user_id}
  end

  test "start new list supervisor" do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserManager.start_list_supervisor(user_id)

    assert Process.alive?(pid)
  end

  test "stop list supervisor by pid", %{pid: pid} do
    assert Process.alive?(pid)
    UserManager.stop_list_supervisor(pid)
    assert not Process.alive?(pid)
  end

  test "stop list supervisor by user id", %{pid: pid, user_id: user_id} do
    assert Process.alive?(pid)
    UserManager.stop_list_supervisor(user_id)
    assert not Process.alive?(pid)
  end
end
