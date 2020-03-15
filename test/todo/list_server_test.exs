defmodule Todo.ListServerTest do
  use ExUnit.Case, async: true

  alias Todo.ListServer

  test "start a list server process" do
    owner_id = UUID.uuid4(:default)
    {:ok, pid} = ListServer.start_link(owner_id)
    {:ok, list} = :sys.get_state(pid)

    assert list.owner_id === owner_id
  end

end
