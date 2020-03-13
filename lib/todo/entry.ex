defmodule Todo.Entry do
  @enforce_keys [:id, :date, :status, :description]
  defstruct @enforce_keys

  @status_options [:open, :closed]

  def new(description) when is_binary(description) do
    %Todo.Entry{
      id: UUID.uuid4(:default),
      date: DateTime.utc_now(),
      status: :open,
      description: description,
    }
  end

  defp replace(entry, key, value) do
    Map.replace!(entry, key, value)
  end

  def update(entry, :status, status) when status in @status_options do
    replace(entry, :status, status)
  end

  def update(entry, :description, description) when is_binary(description) do
    replace(entry, :description, description)
  end

  def serialize(entry) do
    Map.from_struct(entry)
  end
end
