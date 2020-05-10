defmodule Aisf.Records.Record do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aisf.Records.Winner

  schema "records" do
    field(:place, :string)
    field(:record_type, :integer)
    field(:specialty, :string)
    field(:year, :integer)
    has_many(:winners, Winner)

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:record_type, :year, :place, :specialty])
    |> validate_required([:record_type, :year, :place, :specialty])
  end
end
