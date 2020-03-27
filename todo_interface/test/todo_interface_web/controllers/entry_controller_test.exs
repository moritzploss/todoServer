defmodule TodoInterfaceWeb.EntryControllerTest do
  use TodoInterfaceWeb.ConnCase

  alias Todo.UserManager

  setup do
    on_exit(&UserManager.stop_list_managers/0)

    user_id = UUID.uuid4(:default)

    %{"id" => list_id} = build_conn()
    |> post(Routes.user_list_path(build_conn(), :create, user_id))
    |> json_response(200)

    %{ids: %{user_id: user_id, list_id: list_id}}
  end

  test "index/4 responds with all entries in list", %{conn: conn, ids: ids} do
    reponse = conn
    |> get(Routes.user_list_entry_path(conn, :index, ids.user_id, ids.list_id))
    |> json_response(200)

    assert %{"entries" => %{}} = reponse
  end
end
