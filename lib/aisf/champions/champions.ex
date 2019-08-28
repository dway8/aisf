defmodule Aisf.Champions do
  @moduledoc """
  The Champions context.
  """

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Champions.Champion

  @doc """
  Returns the list of champions.

  ## Examples

      iex> list_champions()
      [%Champion{}, ...]

  """
  def list_champions do
    Repo.all(Champion)
    |> Repo.preload([:sport])
  end

  @doc """
  Gets a single champion.

  Raises `Ecto.NoResultsError` if the Champion does not exist.

  ## Examples

      iex> get_champion!(123)
      %Champion{}

      iex> get_champion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_champion!(id), do: Repo.get!(Champion, id)

  @doc """
  Gets a single champion.
  """
  def get_champion(id), do: Repo.get(Champion, id)

  @doc """
  Creates a champion.

  ## Examples

      iex> create_champion(%{field: value})
      {:ok, %Champion{}}

      iex> create_champion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_champion(attrs \\ %{}) do
    attrs = add_pass_hash(attrs)

    %Champion{}
    |> Champion.changeset(attrs)
    |> Repo.insert()
  end

  defp add_pass_hash(params) do
    password = Ecto.UUID.generate() |> binary_part(16, 16)

    params
    |> Map.put(:password, Bcrypt.hash_pwd_salt(password))
  end

  @doc """
  Updates a champion.

  ## Examples

      iex> update_champion(champion, %{field: new_value})
      {:ok, %Champion{}}

      iex> update_champion(champion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_champion(%Champion{} = champion, attrs) do
    champion
    |> Champion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Champion.

  ## Examples

      iex> delete_champion(champion)
      {:ok, %Champion{}}

      iex> delete_champion(champion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_champion(%Champion{} = champion) do
    Repo.delete(champion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking champion changes.

  ## Examples

      iex> change_champion(champion)
      %Ecto.Changeset{source: %Champion{}}

  """
  def change_champion(%Champion{} = champion) do
    Champion.changeset(champion, %{})
  end
end
