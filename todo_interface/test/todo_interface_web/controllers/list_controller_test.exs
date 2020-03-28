defmodule TodoInterfaceWeb.ListControllerTest do
  use TodoInterfaceWeb.ConnCase

  alias Todo.UserManager

  setup_all do
    %{user_id: "123"}
  end

  setup %{user_id: user_id} do
    on_exit(fn -> UserManager.stop_list_manager(user_id) end)
  end

  test "index/3 responds with empty list if user has no lists", %{conn: conn, user_id: user_id} do
    response = conn
      |> get(Routes.user_list_path(conn, :index, user_id))
      |> json_response(200)

    assert response == %{"lists" => []}
  end

  test "index/3 responds with user lists if user has lists", %{conn: conn, user_id: user_id} do
    new_list = conn
      |> post(Routes.user_list_path(conn, :create, user_id, %{name: "My List"}))
      |> json_response(200)

    assert %{"lists" => [^new_list]} = conn
      |> get(Routes.user_list_path(conn, :index, user_id))
      |> json_response(200)
  end

  test "create/3 responds with new list", %{conn: conn, user_id: user_id} do
    response = conn
      |> post(Routes.user_list_path(conn, :create, user_id, %{name: "My List"}))
      |> json_response(200)

    assert %{
      "entries" => %{} = entries,
      "owner_id" => ^user_id,
      "id" => id,
    } = response
  end

  test "show/4 responds with list by id", %{conn: conn, user_id: user_id} do
    newly_created_list = conn
      |> post(Routes.user_list_path(conn, :create, user_id, %{name: "My List"}))
      |> json_response(200)

    assert ^newly_created_list = conn
      |> get(Routes.user_list_path(conn, :show, user_id, newly_created_list["id"]))
      |> json_response(200)
  end

  test "show/4 responds with 404 for unknown id", %{conn: conn, user_id: user_id} do
    %{"error" => _reason} = conn
      |> get(Routes.user_list_path(conn, :show, user_id, "123-unknown"))
      |> json_response(404)
  end

  test "delete/4 deletes list by id", %{conn: conn, user_id: user_id} do
    includes_list_id? = fn %{"lists" => lists}, list_id ->
      list_id in Enum.map(lists, fn %{"id" => id} -> id end)
    end

    %{"id" => list_id} = conn
      |> post(Routes.user_list_path(conn, :create, user_id, %{name: "My List"}))
      |> json_response(200)

    conn
      |> get(Routes.user_list_path(conn, :index, user_id))
      |> json_response(200)
      |> includes_list_id?.(list_id)
      |> assert

    %{} = conn
      |> delete(Routes.user_list_path(conn, :delete, user_id, list_id))
      |> json_response(200)

    conn
      |> get(Routes.user_list_path(conn, :index, user_id))
      |> json_response(200)
      |> includes_list_id?.(list_id)
      |> refute
  end

  test "delete/4 responds with 404 for unknown id", %{conn: conn, user_id: user_id} do
    %{"error" => _reason} = conn
      |> delete(Routes.user_list_path(conn, :delete, user_id, "123-unknown"))
      |> json_response(404)
  end
end
