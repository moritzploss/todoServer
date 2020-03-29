defmodule Repo.UserRepo do

  @collection :user_lists

  def lookup(user_id) do
    case :ets.lookup(@collection, user_id) do
      [] -> {:ok, []}
      [{_key, list_ids}] -> {:ok, list_ids}
    end
  end

  def add(user_id, list_id) do
    {:ok, list_ids} = lookup(user_id)
    case :ets.insert(@collection, {user_id, [list_id | list_ids]}) do
      true -> :ok
      false -> :error
    end
  end

  def delete(user_id, list_id) do
    without_list_id = user_id
      |> lookup
      |> elem(1)
      |> Enum.filter(fn id -> id !== list_id end)

    case :ets.insert(@collection, {user_id, without_list_id}) do
      true -> :ok
      false -> :error
    end
  end

  def drop(user_id) do
    case :ets.delete(@collection, user_id) do
      true -> :ok
      false -> :error
    end
  end
end
