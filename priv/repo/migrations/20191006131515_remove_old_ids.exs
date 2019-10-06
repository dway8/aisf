defmodule Aisf.Repo.Migrations.RemoveOldIds do
  use Ecto.Migration

  def change do
    alter table(:sectors) do
      remove(:old_id)
    end

    alter table(:pro_experiences) do
      remove(:old_champion_id)
    end

    alter table(:medals) do
      remove(:old_champion_id)
    end
  end
end
