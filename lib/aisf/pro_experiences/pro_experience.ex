defmodule Aisf.ProExperiences.ProExperience do
  use Ecto.Schema
  import Ecto.Changeset
  alias Aisf.Champions.Champion
  alias Aisf.Sectors.Sector

  schema "pro_experiences" do
    field(:company_name, :string)
    field(:contact, :string)
    field(:description, :string)
    field(:title, :string)
    field(:website, :string)
    belongs_to(:sector, Sector)
    belongs_to(:champion, Champion)

    timestamps()
  end

  @doc false
  def changeset(pro_experience, attrs) do
    pro_experience
    |> cast(attrs, [
      :title,
      :company_name,
      :description,
      :website,
      :contact
    ])
    |> validate_required([
      :title,
      :company_name,
      :description,
      :website,
      :contact
    ])
  end
end
