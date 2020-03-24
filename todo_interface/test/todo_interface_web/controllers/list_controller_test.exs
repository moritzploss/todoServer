defmodule TodoInterfaceWeb.ListControllerTest do
  use TodoInterfaceWeb.ConnCase

  setup do
    %{user_id: "123"}
  end

  test "index/3 responds with empty list if user has no lists", %{conn: conn, user_id: user_id} do
    response =
      conn
      |> get(Routes.user_list_path(conn, :index, user_id))
      |> json_response(200)

    assert response == %{"lists" => []}
  end

  test "create/3 responds with new list", %{conn: conn, user_id: user_id} do
    response =
      conn
      |> post(Routes.user_list_path(conn, :create, user_id))
      |> json_response(200)

    assert %{
      "entries" => %{} = entries,
      "owner_id" => ^user_id,
      "id" => id,
    } = response

    assert %{} = conn
    |> delete(Routes.user_list_path(conn, :delete, user_id, id))
    |> json_response(200)
  end
end
