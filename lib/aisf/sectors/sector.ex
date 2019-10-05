defmodule Aisf.Sectors.Sector do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aisf.ProExperiences.ProExperience

  schema "sectors" do
    field(:name, :string)
    field(:old_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(sector, attrs) do
    sector
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
