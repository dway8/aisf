defmodule Aisf.Champions.Store.PostgresAdapter.Medal do
  use Ecto.Schema

  alias Aisf.Champions.Store.PostgresAdapter.Champion

  schema "medals" do
    field(:competition, :string)
    field(:medal_type, :integer)
    field(:specialty, :string)
    field(:year, :integer)
    belongs_to(:champion, Champion)

    timestamps()
  end
end
