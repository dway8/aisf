defmodule Aisf.Repo.Migrations.CreatePictures do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add(:filename, :string)
      add(:champion_id, references(:champions))

      timestamps()
    end
  end
end
