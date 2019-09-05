defmodule Aisf.Repo.Migrations.UpdateChampionsWithYearsInFrenchTeam do
  use Ecto.Migration

  def change do
    alter table(:champions) do
      add(:years_in_french_team, {:array, :integer})
    end
  end
end
