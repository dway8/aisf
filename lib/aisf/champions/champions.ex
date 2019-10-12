defmodule Aisf.Champions do
  @moduledoc """
  The Champions context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Champions.Champion
  alias Aisf.ProExperiences.ProExperiences
  alias Aisf.Pictures.Pictures
  alias Aisf.Medals.{Medals, Medal}
  alias Aisf.UploadUtils

  @upload_dir Application.get_env(:aisf, AisfWeb.Endpoint)[:upload_dir]

  @doc """
  Returns the list of champions.
  """
  def list_champions do
    Repo.all(Champion)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals, :pictures])
  end

  @doc """
  Returns the list of members.
  """
  def list_members do
    Repo.all(from(c in Champion, where: c.is_member == true))
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals, :pictures])
  end

  @doc """
  Returns the list of champions with medals.
  """
  def list_champions_with_medals do
    Repo.all(
      from(c in Champion, join: m in Medal, on: m.champion_id == c.id, group_by: c.id, select: c)
    )
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals, :pictures])
  end

  @doc """
  Gets a single champion.

  Raises `Ecto.NoResultsError` if the Champion does not exist.
  """
  def get_champion!(id) do
    Repo.get!(Champion, id)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals, :pictures])
  end

  @doc """
  Gets a single champion.
  """
  def get_champion(id) do
    Repo.get(Champion, id)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals, :pictures])
  end

  @doc """
  Creates a champion.
  """
  def create_champion(attrs \\ %{}) do
    %Champion{}
    |> Champion.changeset(attrs)
    |> Repo.insert()
    |> (fn {:ok, champion} ->
          attrs.pro_experiences
          |> Enum.map(fn p -> ProExperiences.create_pro_experience(champion, p) end)

          attrs.medals
          |> Enum.map(fn m -> Medals.create_medal(champion, m) end)

          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload([:medals, :pictures])}
        end).()
  end

  @doc """
  Updates a champion.

  ## Examples
  """
  def update_champion(%Champion{} = champion, attrs) do
    new_attrs =
      if Map.has_key?(attrs, :profile_picture) && Map.has_key?(attrs.profile_picture, :base64) do
        %{filename: filename, base64: base64} = attrs.profile_picture
        file = UploadUtils.data_url_to_upload(base64)
        extension = Path.extname(filename)
        new_filename = "#{champion.id}-profile#{extension}"

        UploadUtils.copy_file_to_dest(file, new_filename, @upload_dir)

        attrs
        |> Map.put(:profile_picture_filename, new_filename)
        |> Map.delete(:profile_picture)
      else
        attrs
      end

    champion
    |> Champion.changeset(new_attrs)
    |> Repo.update()
    |> (fn {:ok, _champion} ->
          new_attrs.pro_experiences
          |> Enum.map(fn p ->
            if p.id == "new" do
              ProExperiences.create_pro_experience(champion, p)
            else
              p.id
              |> ProExperiences.get_pro_experience!()
              |> ProExperiences.update_pro_experience(p)
            end
          end)

          new_attrs.medals
          |> Enum.map(fn m ->
            if m.id == "new" do
              Medals.create_medal(champion, m)
            else
              m.id
              |> Medals.get_medal!()
              |> Medals.update_medal(m)
            end
          end)

          new_attrs.pictures
          |> Enum.map(fn p ->
            if p.id == "new" do
              Pictures.create_picture(champion, p)
            else
              p.id
              |> Pictures.get_picture!()
              |> Pictures.update_picture(p)
            end
          end)

          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload([:medals, :pictures])}
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
