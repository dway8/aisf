defmodule Aisf.Repo.Migrations.CreateChampions do
  use Ecto.Migration

  def change do
    create table(:champions) do
      add(:last_name, :string)
      add(:first_name, :string)
      add(:email, :string)
      add(:password, :string)
      add(:sport, :string)
      add(:intro, :text)

      timestamps()
    end
  end
end
