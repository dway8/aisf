defmodule Aisf.Medals do
  @moduledoc """
  The Medals context.
  """

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

  ## Examples

      iex> create_medal(%{field: value})
      {:ok, %Medal{}}

      iex> create_medal(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_medal(attrs \\ %{}) do
    %Medal{}
    |> Medal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a medal.

  ## Examples

      iex> update_medal(medal, %{field: new_value})
      {:ok, %Medal{}}

      iex> update_medal(medal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_medal(%Medal{} = medal, attrs) do
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
