defmodule Aisf.Medals.Medal do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aisf.Champions.Champion

  schema "medals" do
    field(:competition, :string)
    field(:medal_type, :integer)
    field(:specialty, :string)
    field(:year, :integer)
    belongs_to(:champion, Champion)
    field(:old_champion_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(medal, attrs) do
    medal
    |> cast(attrs, [:competition, :year, :specialty, :medal_type])
    |> validate_required([:competition, :year, :specialty, :medal_type])
  end
end
