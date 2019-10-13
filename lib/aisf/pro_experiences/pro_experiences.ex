defmodule Aisf.ProExperiences.ProExperiences do
  @moduledoc """
  The ProExperiences context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.ProExperiences.ProExperience

  @doc """
  Returns the list of pro_experiences.

  ## Examples

      iex> list_pro_experiences()
      [%ProExperience{}, ...]

  """
  def list_pro_experiences do
    Repo.all(ProExperience)
  end

  @doc """
  Gets a single pro_experience.

  Raises `Ecto.NoResultsError` if the Pro experience does not exist.

  ## Examples

      iex> get_pro_experience!(123)
      %ProExperience{}

      iex> get_pro_experience!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pro_experience!(id), do: Repo.get!(ProExperience, id)

  @doc """
  Creates a pro_experience.

  """
  def create_pro_experience(champion, attrs \\ %{}) do
    Logger.info("Creating pro experience for champion #{champion.id} with attrs #{attrs}")

    champion
    |> Ecto.build_assoc(:pro_experiences)
    |> ProExperience.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pro_experience.

  ## Examples

  """
  def update_pro_experience(%ProExperience{} = pro_experience, attrs) do
    Logger.info("Updating pro experience #{pro_experience.id} with attrs #{attrs}")

    pro_experience
    |> Repo.preload(:sectors)
    |> ProExperience.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ProExperience.

  ## Examples

      iex> delete_pro_experience(pro_experience)
      {:ok, %ProExperience{}}

      iex> delete_pro_experience(pro_experience)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pro_experience(%ProExperience{} = pro_experience) do
    Repo.delete(pro_experience)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pro_experience changes.

  ## Examples

      iex> change_pro_experience(pro_experience)
      %Ecto.Changeset{source: %ProExperience{}}

  """
  def change_pro_experience(%ProExperience{} = pro_experience) do
    ProExperience.changeset(pro_experience, %{})
  end
end
