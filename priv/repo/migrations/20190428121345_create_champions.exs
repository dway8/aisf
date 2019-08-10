defmodule Aisf.Repo.Migrations.CreateChampions do
  use Ecto.Migration

  def change do
    create table(:champions) do
      add(:last_name, :string)
      add(:first_name, :string)
      add(:email, :string, null: false)
      add(:password, :string)

      timestamps()
    end

    create(unique_index(:champions, [:email]))
  end
end
