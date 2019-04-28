defmodule Aisf.Champions.Champion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "champions" do
    field(:first_name, :string)
    field(:last_name, :string)

    timestamps()
  end

  @doc false
  def changeset(champion, attrs) do
    champion
    |> cast(attrs, [:last_name, :first_name])
    |> validate_required([:last_name, :first_name])
  end
end
