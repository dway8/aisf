defmodule Aisf.Repo.Migrations.CreateMedals do
  use Ecto.Migration

  def change do
    create table(:medals) do
      add :competition, :string
      add :year, :integer
      add :specialty, :string
      add :medal_type, :integer

      timestamps()
    end

  end
end
