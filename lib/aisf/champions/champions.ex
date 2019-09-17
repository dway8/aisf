defmodule Aisf.Champions do
  @moduledoc """
  The Champions context.
  """

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Champions.Champion
  alias Aisf.ProExperiences.ProExperiences
  alias Aisf.Medals.{Medals, Medal}

  @doc """
  Returns the list of champions.
  """
  def list_champions do
    Repo.all(Champion)
    |> Repo.preload([:pro_experiences, :medals])
  end

  @doc """
  Returns the list of members.
  """
  def list_members do
    Repo.all(from(c in Champion, where: c.is_member == true))
    |> Repo.preload([:pro_experiences, :medals])
  end

  @doc """
  Returns the list of champions with medals.
  """
  def list_champions_with_medals do
    Repo.all(
      from(c in Champion, join: m in Medal, on: m.champion_id == c.id, group_by: c.id, select: c)
    )
    |> Repo.preload([:pro_experiences, :medals])
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
    |> Repo.preload([:pro_experiences, :medals])
  end

  @doc """
  Gets a single champion.
  """
  def get_champion(id) do
    Repo.get(Champion, id)
    |> Repo.preload([:pro_experiences, :medals])
  end

  @doc """
  Creates a champion.
  """
  def create_champion(attrs \\ %{}) do
    attrs =
      attrs
      |> add_pass_hash()

    %Champion{}
    |> Champion.changeset(attrs)
    |> Repo.insert()
    |> (fn {:ok, champion} ->
          attrs.pro_experiences
          |> Enum.map(fn p -> ProExperiences.create_pro_experience(champion, p) end)

          attrs.medals
          |> Enum.map(fn m -> Medals.create_medal(champion, m) end)

          {:ok, champion |> Repo.preload([:pro_experiences, :medals])}
        end).()
  end

  defp add_pass_hash(attrs) do
    password = Ecto.UUID.generate() |> binary_part(16, 16)

    attrs
    |> Map.put(:password, Bcrypt.hash_pwd_salt(password))
  end

  @doc """
  Updates a champion.

  ## Examples
  """
  def update_champion(%Champion{} = champion, attrs) do
    champion
    |> Champion.changeset(attrs)
    |> Repo.update()
    |> (fn {:ok, _champion} ->
          attrs.pro_experiences
          |> Enum.map(fn p ->
            if p.id == "new" do
              ProExperiences.create_pro_experience(champion, p)
            else
              p.id
              |> ProExperiences.get_pro_experience!()
              |> ProExperiences.update_pro_experience(p)
            end
          end)

          attrs.medals
          |> Enum.map(fn m ->
            if m.id == "new" do
              Medals.create_medal(champion, m)
            else
              m.id
              |> Medals.get_medal!()
              |> Medals.update_medal(m)
            end
          end)

          {:ok, champion |> Repo.preload([:pro_experiences, :medals])}
        end).()
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
