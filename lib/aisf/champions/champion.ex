defmodule Aisf.Champions.Champion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "champions" do
    field :firstName, :string
    field :lastName, :string

    timestamps()
  end

  @doc false
  def changeset(champion, attrs) do
    champion
    |> cast(attrs, [:lastName, :firstName])
    |> validate_required([:lastName, :firstName])
  end
end
