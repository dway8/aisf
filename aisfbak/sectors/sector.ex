defmodule Aisf.Sectors.Sector do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sectors" do
    field(:name, :string)

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
