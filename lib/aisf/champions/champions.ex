defmodule Aisf.Champions do
  @moduledoc """
  The Champions context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Champions.Champion
  alias Aisf.ProExperiences.ProExperiences
  alias Aisf.Pictures.{Pictures, Picture}
  alias Aisf.Medals.{Medals, Medal}
  alias Aisf.UploadUtils

  @upload_dir Application.get_env(:aisf, AisfWeb.Endpoint)[:upload_dir]

  @doc """
  Returns the list of champions.
  """
  def list_champions do
    Logger.info("Listing all champions")

    Repo.all(Champion)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals])
    |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))
  end

  @doc """
  Returns the list of champions with medals.
  """
  def list_champions_with_medals do
    Logger.info("Listing all champions with medals")

    Repo.all(
      from(c in Champion, join: m in Medal, on: m.champion_id == c.id, group_by: c.id, select: c)
    )
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals])
    |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))
  end

  @doc """
  Gets a single champion.

  Raises `Ecto.NoResultsError` if the Champion does not exist.
  """
  def get_champion!(id) do
    Repo.get!(Champion, id)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals])
    |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))
  end

  @doc """
  Gets a single champion.
  """
  def get_champion(id) do
    Logger.info("Getting champion with id #{id}")

    Repo.get(Champion, id)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals])
    |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))
  end

  @doc """
  Creates a champion.
  """
  def create_champion(attrs \\ %{}) do
    Logger.info("Creating new champion")

    %Champion{}
    |> Champion.changeset(attrs)
    |> Repo.insert()
    |> (fn {:ok, champion} ->
          Logger.info("Creating champion OK with id #{champion.id}")

          attrs.pro_experiences
          |> Enum.map(fn p -> ProExperiences.create_pro_experience(champion, p) end)

          attrs.medals
          |> Enum.map(fn m -> Medals.create_medal(champion, m) end)

          if Map.has_key?(attrs, :profile_picture) && Map.has_key?(attrs.profile_picture, :base64) do
            {:ok, champion} = update_profile_picture(champion, attrs.profile_picture)
          end

          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload([:medals])
           |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}
        end).()
  end

  @doc """
  Updates a champion.

  ## Examples
  """
  def update_champion(%Champion{} = champion, attrs) do
    Logger.info("Updating champion with id #{champion.id}")

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

          attrs.pictures
          |> Enum.map(fn p ->
            if p.id == "new" do
              Pictures.create_picture(champion, p)
            else
              picture = Pictures.get_picture!(p.id)

              if picture.filename !== p.attachment.filename do
                champion
                |> Pictures.update_picture(picture, p)
              end
            end
          end)

          if Map.has_key?(attrs, :profile_picture) && Map.has_key?(attrs.profile_picture, :base64) do
            {:ok, champion} = update_profile_picture(champion, attrs.profile_picture)
          end

          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload([:medals])
           |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}
        end).()
  end

  defp update_profile_picture(champion, profile_picture_attrs) do
    Logger.info("Uploading profile picture for champion #{champion.id}")
    %{filename: filename, base64: base64} = profile_picture_attrs
    file = UploadUtils.data_url_to_upload(base64)
    extension = Path.extname(filename)
    new_filename = "#{champion.id}-profile#{extension}"

    UploadUtils.copy_file_to_dest(file, new_filename, @upload_dir)

    champion
    |> Champion.changeset(%{profile_picture_filename: new_filename})
    |> Repo.update()
  end

  @doc """
  Deletes a Champion.
  """
  def delete_champion(%Champion{} = champion) do
    Repo.delete(champion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking champion changes.
  """
  def change_champion(%Champion{} = champion) do
    Champion.changeset(champion, %{})
  end
end
