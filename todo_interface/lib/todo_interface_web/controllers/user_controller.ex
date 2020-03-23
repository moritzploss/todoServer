defmodule TodoInterfaceWeb.UserController do
  use TodoInterfaceWeb, :controller

  def index(conn, _params) do
    json(conn, %{hello: "hello"})
  end

  def show(conn, %{"id" => id}) do
    json(conn, %{id: id})
  end

  def create(conn, %{"name" => name, "email" => email}) do
    json(conn, %{name: name, email: email})
  end

  def update(conn, %{"id" => id, "name" => name}) do
    json(conn, %{id: id, name: name})
  end

  def delete(conn, %{"id" => id}) do
    json(conn, %{id: id})
  end
end
