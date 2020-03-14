defmodule Todo.Entry do
  alias Todo.Entry

  @enforce_keys [:id, :date, :status, :description]
  defstruct @enforce_keys

  @status_options [:open, :closed]

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

  def update(%Entry{} = entry, :status, status) when status in @status_options do
    {:ok, replace(entry, :status, status)}
  end

  def update(%Entry{} = entry, :description, description) when is_binary(description) do
    {:ok, replace(entry, :description, description)}
  end

  def serialize!(%Entry{} = entry) do
    Map.from_struct(entry)
  end
end
