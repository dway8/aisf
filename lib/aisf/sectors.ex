defmodule Aisf.Sectors do
  @moduledoc """
  The Sectors context.
  """

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Sectors.Sector

  @doc """
  Returns the list of sectors.
  """
  def list_sectors do
    Repo.all(Sector)
  end

  @doc """
  Gets a single sector.

  Raises `Ecto.NoResultsError` if the Sector does not exist.
  """
  def get_sector!(id), do: Repo.get!(Sector, id)

  @doc """
  Creates a sector.
  """
  def create_sector(attrs \\ %{}) do
    %Sector{}
    |> Sector.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sector.
  """
  def update_sector(%Sector{} = sector, attrs) do
    sector
    |> Sector.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Sector.
  """
  def delete_sector(%Sector{} = sector) do
    Repo.delete(sector)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sector changes.
  """
  def change_sector(%Sector{} = sector) do
    Sector.changeset(sector, %{})
  end
end
