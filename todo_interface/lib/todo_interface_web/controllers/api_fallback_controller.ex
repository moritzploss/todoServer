defmodule TodoInterfaceWeb.ApiFallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "not found"})
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(500)
    |> json(%{error: reason})
  end

  def call(conn, _any) do
    conn
    |> put_status(500)
    |> json(%{error: "internal server error"})
  end
end
