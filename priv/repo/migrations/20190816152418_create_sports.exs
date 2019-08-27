defmodule Aisf.Repo.Migrations.CreateSports do
  use Ecto.Migration

  def change do
    create table(:sports) do
      add(:name, :string)

      timestamps()
    end

    alter table(:champions) do
      add(:sport_id, references(:sports), null: true)
    end
  end
end
