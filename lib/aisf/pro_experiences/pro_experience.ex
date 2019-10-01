defmodule Aisf.ProExperiences.ProExperience do
  use Ecto.Schema
  import Ecto.Changeset
  alias Aisf.Champions.Champion
  alias Aisf.Sectors.{Sectors, Sector}
  alias Aisf.Repo

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

  @doc false
  def changeset(pro_experience, attrs) do
    pro_experience
    |> cast(attrs, [
      :title,
      :company_name,
      :description,
      :website,
      :contact,
      :champion_id
    ])
    |> validate_required([
      :title,
      :company_name,
      :description,
      :website,
      :contact,
      :champion_id
    ])
    |> put_assoc(:sectors, parse_sectors(attrs))
  end

  defp parse_sectors(attrs) do
    (attrs.sectors || [])
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&get_or_insert_sector/1)
  end

  defp get_or_insert_sector(name) do
    Repo.get_by(Sector, name: name) ||
      Repo.insert!(Sector, %Sector{name: name})
  end
end
