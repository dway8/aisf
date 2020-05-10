defmodule Aisf.Champions.Store.PostgresAdapter do
  @moduledoc false

  # import Ecto.Query
  #
  # alias Ecto.Changeset
  # alias Ecto.Queryable
  # alias Ecto.UUID
  alias Aisf.Champions.Store.Champion
  alias Aisf.Champions.Store.PostgresAdapter
  alias Aisf.Champions.Store.PostgresAdapter.Repo

  @behaviour Aisf.Champions.Store.Behaviour

  @doc false
  defdelegate child_spec(opts), to: __MODULE__.Supervisor

  @impl true
  @spec list_champions_lite() :: [Champion.t()]
  def list_champions_lite() do
    Repo.all(PostgresAdapter.Champion)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals])
  end
end
