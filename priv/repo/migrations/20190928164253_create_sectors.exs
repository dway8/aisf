defmodule Aisf.Repo.Migrations.CreateSectors do
  use Ecto.Migration

  def change do
    create table(:sectors) do
      add(:name, :string)

      timestamps()
    end

    alter table(:pro_experiences) do
      remove(:occupational_category)
      add(:sector_id, references(:sectors))
    end
  end
end
