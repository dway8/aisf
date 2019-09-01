defmodule Aisf.ProExperiences.ProExperience do
  use Ecto.Schema
  import Ecto.Changeset
  alias Aisf.Champions.Champion

  schema "pro_experiences" do
    field(:company_name, :string)
    field(:contact, :string)
    field(:description, :string)
    field(:occupational_category, :string)
    field(:title, :string)
    field(:website, :string)
    belongs_to(:champion, Champion)

    timestamps()
  end

  @doc false
  def changeset(pro_experience, attrs) do
    pro_experience
    |> cast(attrs, [
      :occupational_category,
      :title,
      :company_name,
      :description,
      :website,
      :contact
    ])
    |> validate_required([
      :occupational_category,
      :title,
      :company_name,
      :description,
      :website,
      :contact
    ])
  end
end
