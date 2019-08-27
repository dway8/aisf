defmodule Aisf.Sport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sports" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(sport, attrs) do
    sport
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
