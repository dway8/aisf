defmodule Aisf.Repo.Migrations.AddDescriptiveFieldsToChampion do
  use Ecto.Migration

  def change do
    alter table(:champions) do
      add(:french_team_participation, :string)
      add(:olympic_games_participation, :string)
      add(:world_cup_participation, :string)
      add(:track_record, :text)
      add(:best_memory, :text)
      add(:decoration, :text)
      add(:background, :text)
      add(:volunteering, :text)
    end
  end
end
