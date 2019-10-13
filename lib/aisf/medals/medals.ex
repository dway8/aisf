defmodule Aisf.Medals.Medals do
  @moduledoc """
  The Medals context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Medals.Medal

  @doc """
  Returns the list of medals.

  ## Examples

      iex> list_medals()
      [%Medal{}, ...]

  """
  def list_medals do
    Repo.all(Medal)
  end

  @doc """
  Gets a single medal.

  Raises `Ecto.NoResultsError` if the Medal does not exist.

  ## Examples

      iex> get_medal!(123)
      %Medal{}

      iex> get_medal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_medal!(id), do: Repo.get!(Medal, id)

  @doc """
  Creates a medal.
  """
  def create_medal(champion, attrs \\ %{}) do
    Logger.info("Creating medal for champion #{champion.id} with attrs #{attrs}")

    champion
    |> Ecto.build_assoc(:medals)
    |> Medal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a medal.

  ## Examples

  """
  def update_medal(%Medal{} = medal, attrs) do
    Logger.info("Updating medal #{medal.id} with attrs #{attrs}")

    medal
    |> Medal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Medal.

  ## Examples

      iex> delete_medal(medal)
      {:ok, %Medal{}}

      iex> delete_medal(medal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_medal(%Medal{} = medal) do
    Repo.delete(medal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking medal changes.

  ## Examples

      iex> change_medal(medal)
      %Ecto.Changeset{source: %Medal{}}

  """
  def change_medal(%Medal{} = medal) do
    Medal.changeset(medal, %{})
  end
end
