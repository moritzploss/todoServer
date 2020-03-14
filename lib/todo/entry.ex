defmodule Todo.Entry do
  @enforce_keys [:id, :date, :status, :description]
  defstruct @enforce_keys

  @status_options [:open, :closed]

  def new(description) when is_binary(description) do
    {:ok, %Todo.Entry{
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

  def update(entry, :status, status) when status in @status_options do
    {:ok, replace(entry, :status, status)}
  end

  def update(entry, :description, description) when is_binary(description) do
    {:ok, replace(entry, :description, description)}
  end

  def update(_entry, _key, _value) do
    {:error, :invalid_key}
  end

  def serialize(entry) do
    {:ok, Map.from_struct(entry)}
  end
end
