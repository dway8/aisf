defmodule Aisf.Champions.Store.PostgresAdapter.ProExperience do
  use Ecto.Schema
  alias Aisf.Champions.PostgresAdapter.{Champion, Sector}

  schema "pro_experiences" do
    field(:company_name, :string)
    field(:contact, :string)
    field(:description, :string)
    field(:title, :string)
    field(:website, :string)
    belongs_to(:champion, Champion)

    many_to_many(:sectors, Sector, join_through: "pro_experiences_sectors")

    timestamps()
  end
end
