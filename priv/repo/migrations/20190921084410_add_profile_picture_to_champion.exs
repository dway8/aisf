defmodule Aisf.Repo.Migrations.AddProfilePictureToChampion do
  use Ecto.Migration

  def change do
    alter table(:champions) do
      add(:profile_picture_filename, :string)
    end
  end
end
