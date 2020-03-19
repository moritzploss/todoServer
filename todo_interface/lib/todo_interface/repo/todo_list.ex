defmodule TodoInterface.Repo.TodoList do
  use Ecto.Schema

  schema "todolist" do
    field :owner_id, :binary_id
    field :list_id, :binary_id
  end

  def changeset(todo_list, params \\ %{}) do
    todo_list
    |> Ecto.Changeset.cast(params, [:owner_id, :list_id])
    |> Ecto.Changeset.validate_required([:owner_id, :list_id])
  end
end
