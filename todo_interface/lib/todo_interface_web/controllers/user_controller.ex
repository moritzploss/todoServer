defmodule TodoInterfaceWeb.UserController do
  use TodoInterfaceWeb, :controller

  action_fallback TodoInterfaceWeb.ApiFallbackController

  alias Todo.UserManager

  def index(conn, _params) do
    json(conn, %{users: UserManager.which_users()})
  end

  def show(conn, %{"id" => id}) do
    json(conn, %{error: "not implemented"})
  end

  def create(conn, %{"name" => name}) do
    user_id = UUID.uuid4(:default)
    {:ok, _pid} = UserManager.start_list_manager(user_id)
    json(conn, %{name: name, id: user_id})
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "request body must contain key 'name' with value type string"})
  end

  def update(conn, %{"id" => id, "name" => name}) do
    json(conn, %{error: "not implemented"})
  end

  def delete(conn, %{"id" => id}) do
    with :ok <- UserManager.stop_list_manager(id) do
      json(conn, %{})
    end
  end
end
