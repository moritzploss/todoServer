defmodule TodoInterfaceWeb.UserControllerTest do
  use TodoInterfaceWeb.ConnCase

  alias Todo.UserManager

  setup do
    on_exit(&UserManager.stop_list_managers/0)
  end

  test "index/2 responds with user list", %{conn: conn} do
    assert %{"users" => []} = conn
    |> get(Routes.user_path(conn, :index))
    |> json_response(200)
  end

  test "new users can be created and retrieved", %{conn: conn} do
    %{"id" => user_id} = conn
    |> post(Routes.user_path(conn, :create, %{name: "Test User"}))
    |> json_response(200)

    assert %{"users" => [^user_id]} = conn
    |> get(Routes.user_path(conn, :index))
    |> json_response(200)
  end

  test "create/3 handles invalid request parameters", %{conn: conn} do
    %{"error" => _reason} = conn
    |> post(Routes.user_path(conn, :create, %{foo: "Test User"}))
    |> json_response(400)
  end

  test "delete/3 deletes users by id", %{conn: conn} do
    %{"id" => user_id} = conn
    |> post(Routes.user_path(conn, :create, %{name: "Test User"}))
    |> json_response(200)

    assert %{} = conn
    |> delete(Routes.user_path(conn, :delete, user_id))
    |> json_response(200)

    assert %{"users" => []} = conn
    |> get(Routes.user_path(conn, :index))
    |> json_response(200)
  end
end
