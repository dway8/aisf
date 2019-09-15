defmodule Aisf.Repo.Migrations.AddIsMemberToChampion do
  use Ecto.Migration

  def change do
    alter table(:champions) do
      add(:is_member, :boolean)
    end
  end
end
