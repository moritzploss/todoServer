defmodule TodoInterfaceWeb.EntryControllerTest do
  use TodoInterfaceWeb.ConnCase

  alias Todo.UserManager

  setup do
    on_exit(&UserManager.stop_list_managers/0)

    user_id = UUID.uuid4(:default)

    %{"id" => list_id} = build_conn()
      |> post(Routes.user_list_path(build_conn(), :create, user_id, %{name: "test list"}))
      |> json_response(200)

    %{ids: %{user_id: user_id, list_id: list_id}}
  end

  test "index/4 responds with all entries in list", %{conn: conn, ids: ids} do
    reponse = conn
      |> get(Routes.user_list_entry_path(conn, :index, ids.user_id, ids.list_id))
      |> json_response(200)

    assert %{"entries" => %{}} = reponse
  end

  test "show/4 responds with entry", %{conn: conn, ids: ids} do
    %{user_id: user_id, list_id: list_id} = ids

    post_body = %{"description" => "Create an entry!"}
    %{"id" => entry_id} = conn
      |> post(Routes.user_list_entry_path(conn, :create, user_id, list_id, post_body))
      |> json_response(200)

    get_response = conn
      |> get(Routes.user_list_entry_path(conn, :show, user_id, list_id, entry_id))
      |> json_response(200)

    assert %{
      "id" => ^entry_id,
      "description" => _description,
    } = get_response
  end

  test "create/5 responds newly created entry", %{conn: conn, ids: ids} do
    description = "Make the test pass!"
    body = %{"description" => description}
    %{user_id: user_id, list_id: list_id} = ids

    response = conn
      |> post(Routes.user_list_entry_path(conn, :create, user_id, list_id, body))
      |> json_response(200)

    assert %{
      "id" => _id,
      "date" => _date,
      "status" => _status,
      "description" => ^description
    } = response
  end

  test "update/6 responds with updated entry", %{conn: conn, ids: ids} do
    %{user_id: user_id, list_id: list_id} = ids

    post_body = %{"description" => "Write a failing test!"}
    %{"id" => entry_id} = conn
      |> post(Routes.user_list_entry_path(conn, :create, user_id, list_id, post_body))
      |> json_response(200)

    new_description = "Make it pass!"
    put_body = %{"description" => new_description}
    put_response = conn
      |> patch(Routes.user_list_entry_path(conn, :update, user_id, list_id, entry_id, put_body))
      |> json_response(200)

    assert %{
      "id" => _id,
      "date" => _date,
      "status" => _status,
      "description" => ^new_description
    } = put_response
  end

  test "delete/5 responds with updated entry", %{conn: conn, ids: ids} do
    %{user_id: user_id, list_id: list_id} = ids

    post_body = %{"description" => "Delete this entry!"}
    %{"id" => entry_id} = conn
      |> post(Routes.user_list_entry_path(conn, :create, user_id, list_id, post_body))
      |> json_response(200)

    %{} = conn
      |> delete(Routes.user_list_entry_path(conn, :delete, user_id, list_id, entry_id))
      |> json_response(200)

    %{"entries" => entries} = conn
      |> get(Routes.user_list_entry_path(conn, :index, user_id, list_id))
      |> json_response(200)

    refute Map.has_key?(entries, entry_id)
  end
end
