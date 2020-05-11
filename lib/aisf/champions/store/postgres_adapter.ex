defmodule Aisf.Champions.Store.PostgresAdapter do
  @moduledoc false

  import Ecto.Query
  #
  # alias Ecto.Changeset
  # alias Ecto.Queryable
  # alias Ecto.UUID
  alias Aisf.Champions.Store.Champion
  alias Aisf.Champions.Store.PostgresAdapter
  alias Aisf.Champions.Store.PostgresAdapter.Picture
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

  @impl true
  @spec get_champion(id :: String.t()) :: {:ok, Champion.t()} | {:error, :not_found}
  def get_champion(id) do
    query =
      Repo.get(PostgresAdapter.Champion, id)
      |> Repo.preload(pro_experiences: [:sectors])
      |> Repo.preload([:medals])
      |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))

    case query do
      %PostgresAdapter.Champion{} = champion ->
        {:ok, champion}

      _ ->
        {:error, :not_found}
    end
  end

  @impl true
  @spec create_champion(map) :: {:ok, Champion.t()} | {:error, :missing_fields}
  def create_champion(args) do
    query =
      %PostgresAdapter.Champion{}
      |> PostgresAdapter.Champion.changeset(args)
      |> Repo.insert()

    case query do
      {:ok, champion} ->
        {:ok,
         champion
         |> Repo.preload(pro_experiences: [:sectors])
         |> Repo.preload([:medals])
         |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}

      _ ->
        {:error, :missing_fields}
    end
  end

  @impl true
  @spec generate_next_login() :: integer()
  def generate_next_login() do
    case Repo.one(from(c in PostgresAdapter.Champion, select: max(c.login))) do
      nil ->
        1

      val ->
        val + 1
    end
  end
end
