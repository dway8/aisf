defmodule Aisf.Repo.Migrations.CreateChampions do
  use Ecto.Migration

  def change do
    create table(:champions) do
      add(:last_name, :string)
      add(:first_name, :string)

      timestamps()
    end
  end
end
