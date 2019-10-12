defmodule Aisf.Pictures.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aisf.Champions.Champion

  schema "pictures" do
    field(:filename, :string)
    belongs_to(:champion, Champion)

    timestamps()
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:filename])
    |> validate_required([:filename])
  end
end
