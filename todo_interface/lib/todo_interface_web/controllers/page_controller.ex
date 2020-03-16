defmodule TodoInterfaceWeb.PageController do
  use TodoInterfaceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
