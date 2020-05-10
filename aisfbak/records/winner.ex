defmodule Aisf.Records.Winner do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aisf.Records.Record

  schema "winners" do
    field(:last_name, :string)
    field(:first_name, :string)
    field(:position, :integer)
    belongs_to(:record, Record)

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:last_name, :first_name, :position, :record_id])
    |> validate_required([:last_name, :first_name, :position, :record_id])
  end
end
