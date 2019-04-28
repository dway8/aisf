defmodule Aisf.Repo.Migrations.CreateChampions do
  use Ecto.Migration

  def change do
    create table(:champions) do
      add :lastName, :string
      add :firstName, :string

      timestamps()
    end

  end
end
