defmodule Aisf.Champions.Store.PostgresAdapter.Sector do
  use Ecto.Schema

  schema "sectors" do
    field(:name, :string)

    timestamps()
  end
end
