defmodule Aisf.Repo.Migrations.LinkMedalToChampion do
  use Ecto.Migration

  def change do
    alter table(:medals) do
      add(:champion_id, references(:champions))
    end
  end
end
