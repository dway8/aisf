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
      add(:birth_date, :string)
      add(:address, :string)
      add(:phone_number, :string)
      add(:website, :string)
      add(:old_id, :integer)

      timestamps()
    end
  end
end
