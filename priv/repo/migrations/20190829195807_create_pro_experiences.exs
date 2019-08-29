defmodule Aisf.Repo.Migrations.CreateProExperiences do
  use Ecto.Migration

  def change do
    create table(:pro_experiences) do
      add :occupationalCategory, :string
      add :title, :string
      add :companyName, :string
      add :description, :string
      add :website, :string
      add :contact, :string

      timestamps()
    end

  end
end
