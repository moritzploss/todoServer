defmodule Repo.UserRepo do
  @table :user_lists

  def lookup(user_id) do
    case :ets.lookup(@table, user_id) do
      [] -> {:ok, []}
      [{_key, list_ids}] -> {:ok, list_ids}
    end
  end

  def add(user_id, list_id) do
    {:ok, list_ids} = lookup(user_id)
    :ets.insert(@table, {user_id, [list_id | list_ids]})
    :ok
  end

  def delete(user_id, list_id) do
    without_list_id = user_id
      |> lookup
      |> elem(1)
      |> Enum.filter(fn id -> id !== list_id end)

    :ets.insert(@table, {user_id, without_list_id})
    :ok
  end

  def drop(user_id) do
    :ets.delete(@table, user_id)
    :ok
  end
end
