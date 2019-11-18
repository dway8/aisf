defmodule Aisf.Repo.Migrations.DeleteChampionCascade do
  use Ecto.Migration

  import Ecto.Changeset

  def change do
    execute("ALTER TABLE pro_experiences DROP CONSTRAINT pro_experiences_champion_id_fkey")

    alter table(:pro_experiences) do
      modify(:champion_id, references(:champions, on_delete: :delete_all))
    end

    execute("ALTER TABLE medals DROP CONSTRAINT medals_champion_id_fkey")

    alter table(:medals) do
      modify(:champion_id, references(:champions, on_delete: :delete_all))
    end

    execute(
      "ALTER TABLE pro_experiences_sectors DROP CONSTRAINT pro_experiences_sectors_pro_experience_id_fkey"
    )

    alter table(:pro_experiences_sectors) do
      modify(:pro_experience_id, references(:pro_experiences, on_delete: :delete_all))
    end

    execute("ALTER TABLE pictures DROP CONSTRAINT pictures_champion_id_fkey")

    alter table(:pictures) do
      modify(:champion_id, references(:champions, on_delete: :delete_all))
    end
  end
end
