defmodule Aisf.Repo.Migrations.CreateSectors do
  use Ecto.Migration

  def change do
    create table(:sectors) do
      add(:name, :string)

      timestamps()
    end

    create(unique_index(:sectors, [:name]))

    create table(:pro_experiences_sectors, primary_key: false) do
      add(:sector_id, references(:sectors))
      add(:pro_experience_id, references(:pro_experiences))

      timestamps(default: fragment("now()"))
    end

    alter table(:pro_experiences) do
      remove(:occupational_category)
    end
  end
end
