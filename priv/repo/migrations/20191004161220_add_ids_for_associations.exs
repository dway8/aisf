defmodule Aisf.Repo.Migrations.AddIdsForAssociations do
  use Ecto.Migration

  def change do
    alter table(:medals) do
      add(:old_champion_id, :integer)
    end

    alter table(:pro_experiences) do
      add(:old_champion_id, :integer)
    end

    alter table(:sectors) do
      add(:old_id, :integer)
    end
  end
end
