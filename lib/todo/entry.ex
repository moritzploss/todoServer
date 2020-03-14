defmodule Todo.Entry do
  alias Todo.Entry

  @status_options [:open, :closed]
  @enforce_keys [:id, :date, :status, :description]

  defstruct @enforce_keys

  def new(description) when is_binary(description) do
    {:ok, %Entry{
      id: UUID.uuid4(:default),
      date: DateTime.utc_now(),
      status: :open,
      description: description,
    }}
  end

  def new(_description) do
    {:error, :invalid_description}
  end

  defp replace(entry, key, value) do
    Map.replace!(entry, key, value)
  end

  defp update(%Entry{} = entry, :status, status) when status in @status_options do
    {:ok, replace(entry, :status, status)}
  end

  defp update(%Entry{} = entry, :description, description) when is_binary(description) do
    {:ok, replace(entry, :description, description)}
  end

  defp update(%Entry{} = _entry, _key, _val) do
    {:error, :invalid_key_or_value}
  end

  defp update_while_valid(%Entry{} = entry, %{} = to_update) do
    Enum.reduce_while(Map.keys(to_update), entry, fn key, acc ->
      case update(acc, key, to_update[key]) do
        {:ok, updated_entry} -> {:cont, updated_entry}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  def update(%Entry{} = entry, %{} = to_update) do
    case update_while_valid(entry, to_update) do
      {:error, reason} -> {:error, reason}
      updated_entry -> {:ok, updated_entry}
    end
  end

  def serialize!(%Entry{} = entry) do
    Map.from_struct(entry)
  end
end
