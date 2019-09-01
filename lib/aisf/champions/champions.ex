defmodule Aisf.Champions do
  @moduledoc """
  The Champions context.
  """

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Champions.Champion
  alias Aisf.Sport
  alias Aisf.ProExperiences.ProExperience

  @doc """
  Returns the list of champions.

  ## Examples

      iex> list_champions()
      [%Champion{}, ...]

  """
  def list_champions do
    Repo.all(Champion)
    |> Repo.preload([:sport, :pro_experiences])
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
  def get_champion!(id) do
    Repo.get!(Champion, id)
    |> Repo.preload([:sport, :pro_experiences])
  end

  @doc """
  Gets a single champion.
  """
  def get_champion(id) do
    Repo.get(Champion, id)
    |> Repo.preload([:sport, :pro_experiences])
  end

  @doc """
  Creates a champion.

  ## Examples

      iex> create_champion(%{field: value})
      {:ok, %Champion{}}

      iex> create_champion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_champion(attrs \\ %{}) do
    attrs =
      attrs
      |> add_pass_hash()
      |> link_to_sport()

    %Champion{}
    |> Champion.changeset(attrs)
    |> Repo.insert()
    |> (fn {:ok, champion} -> {:ok, champion |> Repo.preload([:sport, :pro_experiences])} end).()
  end

  defp add_pass_hash(attrs) do
    password = Ecto.UUID.generate() |> binary_part(16, 16)

    attrs
    |> Map.put(:password, Bcrypt.hash_pwd_salt(password))
  end

  defp link_to_sport(attrs) do
    sport_name = attrs.sport
    sport = Sport.get_sport_by_name(sport_name)

    attrs = Map.put(attrs, :sport_id, sport.id)

    Map.delete(attrs, attrs.sport)
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
