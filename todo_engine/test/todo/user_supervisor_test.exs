defmodule Todo.UserSupervisorTest do
  use ExUnit.Case, async: false

  alias Todo.UserSupervisor

  setup do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserSupervisor.start_list_supervisor(user_id)
    %{pid: pid, user_id: user_id}
  end

  test "start new list supervisor" do
    user_id = UUID.uuid4(:default)
    {:ok, pid} = UserSupervisor.start_list_supervisor(user_id)

    assert Process.alive?(pid)
  end

  test "stop list supervisor by pid", %{pid: pid} do
    assert Process.alive?(pid)
    UserSupervisor.stop_list_supervisor(pid)
    assert not Process.alive?(pid)
  end

  test "stop list supervisor by user id", %{pid: pid, user_id: user_id} do
    assert Process.alive?(pid)
    UserSupervisor.stop_list_supervisor(user_id)
    assert not Process.alive?(pid)
  end
end
