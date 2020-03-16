defmodule TodoInterface.Repo.Migrations.Lists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :owner_id, :binary_id
      add :list_id, :binary_id
    end
  end
end
