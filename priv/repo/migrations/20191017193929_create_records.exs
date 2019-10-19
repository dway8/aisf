defmodule Aisf.Repo.Migrations.CreateRecords do
  use Ecto.Migration

  def change do
    create table(:records) do
      add(:record_type, :integer)
      add(:year, :integer)
      add(:place, :string)
      add(:specialty, :string)

      timestamps()
    end

    create table(:winners) do
      add(:last_name, :string)
      add(:first_name, :string)
      add(:position, :integer)
      add(:record_id, references(:records))

      timestamps()
    end
  end
end
