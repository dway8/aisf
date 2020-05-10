defmodule Aisf.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field(:competition, :string)
    field(:place, :string)
    field(:sport, :string)
    field(:year, :integer)

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:competition, :sport, :year, :place])
    |> validate_required([:competition, :year, :place])
  end
end
