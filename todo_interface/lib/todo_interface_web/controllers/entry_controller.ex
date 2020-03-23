defmodule TodoInterfaceWeb.EntryController do
  use TodoInterfaceWeb, :controller

  def index(conn, %{"list_id" => list_id, "user_id" => user_id}) do
    json(conn, %{entries: %{}})
  end

  def show(conn, %{"id" => id, "list_id" => list_id, "user_id" => user_id}) do
    json(conn, %{id: id, list_id: list_id, user_id: user_id})
  end

  def create(conn, %{"description" => description, "list_id" => list_id, "user_id" => user_id}) do
    json(conn, %{description: description, list_id: list_id, user_id: user_id})
  end

  def update(conn, %{"id" => id, "list_id" => list_id, "user_id" => user_id} = params) do
    json(conn, params)
  end

  def delete(conn, %{"id" => id, "list_id" => list_id, "user_id" => user_id}) do
    json(conn, %{id: id, list_id: list_id, user_id: user_id})
  end
end
