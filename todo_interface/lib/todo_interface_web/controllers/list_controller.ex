defmodule TodoInterfaceWeb.ListController do
  use TodoInterfaceWeb, :controller

  def index(conn, %{"user_id" => user_id}) do
    json(conn, %{user_id: user_id})
  end

  def show(conn, %{"id" => id, "user_id" => user_id}) do
    json(conn, %{id: id, user_id: user_id})
  end

  def create(conn, _params) do
    json(conn, %{})
  end

  def delete(conn, %{"id" => id, "user_id" => user_id}) do
    json(conn, %{id: id, user_id: user_id})
  end
end
