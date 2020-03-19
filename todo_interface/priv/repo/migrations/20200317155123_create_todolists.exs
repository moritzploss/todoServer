defmodule TodoInterface.Repo.Migrations.CreateTodolists do
  use Ecto.Migration

  def change do
    create table(:todolists) do
      add :owner_id, :binary_id
      add :list_id, :binary_id
    end
  end
end
