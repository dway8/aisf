defmodule Aisf.ProExperiences.ProExperience do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pro_experiences" do
    field :companyName, :string
    field :contact, :string
    field :description, :string
    field :occupationalCategory, :string
    field :title, :string
    field :website, :string

    timestamps()
  end

  @doc false
  def changeset(pro_experience, attrs) do
    pro_experience
    |> cast(attrs, [:occupationalCategory, :title, :companyName, :description, :website, :contact])
    |> validate_required([:occupationalCategory, :title, :companyName, :description, :website, :contact])
  end
end
