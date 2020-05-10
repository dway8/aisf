defmodule Aisf.Champions.Store.PostgresAdapter.Picture do
  use Ecto.Schema

  alias Aisf.Champions.PostgresAdapter.Champion

  schema "pictures" do
    field(:filename, :string)
    belongs_to(:champion, Champion)

    timestamps()
  end
end
