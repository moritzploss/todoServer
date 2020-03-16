defmodule TodoInterface.Repo.List do
  use Ecto.Schema

  schema "lists" do
    field :owner_id, :binary_id
    field :list_id, :binary_id
  end
end
