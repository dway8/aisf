defmodule Aisf.Repo.Migrations.RemoveChampionsPassword do
  use Ecto.Migration

  def change do
    alter table(:champions) do
      remove(:password)
    end
  end
end
