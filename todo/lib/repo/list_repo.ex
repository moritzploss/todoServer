defmodule Repo.ListRepo do
  @table :list_state

  def lookup(list_id) do
    case :ets.lookup(@table, list_id) do
      [] -> {:ok, nil}
      [{_key, list}] -> {:ok, list}
    end
  end

  def save(list) do
    :ets.insert(@table, {list.id, list})
    :ok
  end

  def drop(list_id) do
    :ets.delete(@table, list_id)
    :ok
  end
end
