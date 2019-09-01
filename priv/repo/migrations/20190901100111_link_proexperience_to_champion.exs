defmodule Aisf.Repo.Migrations.LinkProexperienceToChampion do
  use Ecto.Migration

  def change do
    alter table(:pro_experiences) do
      add(:champion_id, references(:champions))
    end
  end
end
