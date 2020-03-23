defmodule TodoInterfaceWeb.EntryControllerTest do
  use TodoInterfaceWeb.ConnCase

  setup do
    %{params: %{user_id: 1, list_id: 2}}
  end

  test "index/4 responds with all entries in list", %{conn: conn, params: params} do
    response =
      conn
      |> get(Routes.user_list_entry_path(conn, :index, params.user_id, params.list_id))
      |> json_response(200)

    expected = %{"entries" => %{}}

    assert response == expected
  end
end
