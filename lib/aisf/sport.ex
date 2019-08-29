defmodule Aisf.Sport do
  use Ecto.Schema
  import Ecto.Changeset
  alias Aisf.Repo

  alias Aisf.Sport

  schema "sports" do
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(sport, attrs) do
    sport
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc """
  Gets a single sport by its name.
  """
  def get_sport_by_name(name) do
    Repo.get_by(Sport, name: name)
  end
end
