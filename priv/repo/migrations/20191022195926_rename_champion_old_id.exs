defmodule Aisf.Repo.Migrations.RenameChampionOldId do
  use Ecto.Migration

  def change do
    rename(table(:champions), :old_id, to: :login)
    create(unique_index(:champions, [:login]))
  end
end
