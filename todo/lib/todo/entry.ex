defmodule Todo.Entry do
  alias Todo.Entry

  @status_options [:open, :closed]
  @enforce_keys [:id, :date, :status, :description]

  @derive {Jason.Encoder, only: [:id, :date, :status, :description]}
  defstruct @enforce_keys

  def new(description) when is_binary(description) do
    {:ok, %Entry{
      id: UUID.uuid4(:default),
      date: DateTime.utc_now(),
      status: :open,
      description: description,
    }}
  end

  def new(_description), do: {:error, :invalid_description}

  defp replace(%Entry{} = entry, :status, status) when status in @status_options do
    {:ok, Map.replace!(entry, :status, status)}
  end

  defp replace(%Entry{} = entry, :description, description) when is_binary(description) do
    {:ok,  Map.replace!(entry, :description, description)}
  end

  defp replace(%Entry{} = _entry, _key, _val) do
    {:error, :invalid_key_or_value}
  end

  defp perform_valid_updates(%Entry{} = current_entry, %{} = updates) do
    Enum.reduce_while(Map.to_list(updates), current_entry,
      fn {key, val}, entry ->
        case replace(entry, key, val) do
          {:ok, updated_entry} -> {:cont, updated_entry}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
  end

  def update(%Entry{} = entry, %{} = updates) do
    case perform_valid_updates(entry, updates) do
      {:error, reason} -> {:error, reason}
      updated_entry -> {:ok, updated_entry}
    end
  end
end
