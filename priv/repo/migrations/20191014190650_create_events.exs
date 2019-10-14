defmodule Aisf.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :competition, :string
      add :sport, :string
      add :year, :integer
      add :place, :string

      timestamps()
    end

  end
end
