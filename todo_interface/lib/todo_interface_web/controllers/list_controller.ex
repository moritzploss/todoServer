defmodule TodoInterfaceWeb.ListController do
  use TodoInterfaceWeb, :controller

  action_fallback TodoInterfaceWeb.ApiFallbackController

  alias Todo.{ListManager, ListServer, UserManager}

  defp get_list_manager(user_id) when is_binary(user_id) do
    user_id
    |> UserManager.get_or_create_list_manager
    |> elem(1)
  end

  def index(conn, %{"user_id" => user_id}) do
    lists = user_id
    |> get_list_manager
    |> ListManager.get_lists

    json(conn, %{lists: lists})
  end

  def show(conn, %{"id" => id, "user_id" => user_id}) do
    with {:ok, list} <- user_id
      |> get_list_manager
      |> ListManager.get_list(id)
    do
      json(conn, list)
    end
  end

  def create(conn, %{"user_id" => user_id}) do
    {:ok, list} = user_id
    |> get_list_manager
    |> ListManager.start_list
    |> elem(1)
    |> ListServer.get_list

    json(conn, list)
  end

  def delete(conn, %{"id" => id, "user_id" => user_id}) do
    with :ok <- user_id
      |> get_list_manager
      |> ListManager.stop_list(id)
    do
      json(conn, %{})
    end
  end
end
