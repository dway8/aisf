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
  alias Aisf.Medals.{Medals}
  alias Aisf.UploadUtils

  @upload_dir Application.get_env(:aisf, AisfWeb.Endpoint)[:upload_dir]

  @doc """
  Returns the list of champions.
  """
  def list_champions_lite do
    Logger.info("Listing all champions")

    Repo.all(Champion)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload([:medals])
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
    Logger.info("Creating new champion with attrs #{inspect(attrs)}")

    attrs =
      attrs
      |> Map.put(:login, generate_next_login())

    %Champion{}
    |> Champion.changeset(attrs)
    |> Repo.insert()
    |> (fn {:ok, champion} ->
          Logger.info("Creating champion OK with id #{champion.id}")

          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload([:medals])
           |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}
        end).()
  end

  @doc """
  Updates a champion presentation.

  ## Examples
  """
  def update_presentation(%Champion{} = champion, attrs) do
    Logger.info("Updating presentation of champion #{champion.id} with attrs #{inspect(attrs)}")

    champion
    |> Champion.presentation_changeset(attrs)
    |> Repo.update()
    |> (fn {:ok, champion} ->
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
  Updates a champion private info.

  ## Examples
  """
  def update_private_info(%Champion{} = champion, attrs) do
    Logger.info("Updating private info of champion #{champion.id} with attrs #{inspect(attrs)}")

    champion
    |> Champion.private_info_changeset(attrs)
    |> Repo.update()
    |> (fn {:ok, champion} ->
          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload([:medals])
           |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}
        end).()
  end

  @doc """
  Updates a champion sport career.

  ## Examples
  """
  def update_sport_career(%Champion{} = champion, attrs) do
    Logger.info("Updating sport career of champion #{champion.id} with attrs #{inspect(attrs)}")

    champion
    |> Champion.sport_career_changeset(attrs)
    |> Repo.update()
    |> (fn {:ok, champion} ->
          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload([:medals])
           |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}
        end).()
  end

  @doc """
  Updates a champion professional career.

  ## Examples
  """
  def update_professional_career(%Champion{} = champion, attrs) do
    Logger.info(
      "Updating professional career of champion #{champion.id} with attrs #{inspect(attrs)}"
    )

    champion
    |> Champion.professional_career_changeset(attrs)
    |> Repo.update()
    |> (fn {:ok, champion} ->
          update_pro_experiences(champion, attrs.pro_experiences)

          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload([:medals])
           |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}
        end).()
  end

  @doc """
  Updates a champion pictures.

  ## Examples
  """
  def update_pictures(%Champion{} = champion, attrs) do
    Logger.info("Updating pictures of champion #{champion.id} with attrs #{inspect(attrs)}")

    do_update_pictures(champion, attrs.pictures)

    {:ok,
     champion
     |> Repo.preload(pro_experiences: [:sectors])
     |> Repo.preload([:medals])
     |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}
  end

  @doc """
  Updates a champion private info.

  ## Examples
  """
  def update_medals(%Champion{} = champion, attrs) do
    Logger.info("Updating medals of champion #{champion.id} with attrs #{inspect(attrs)}")

    do_update_medals(champion, attrs.medals)

    {:ok,
     champion
     |> Repo.preload(pro_experiences: [:sectors])
     |> Repo.preload([:medals])
     |> Repo.preload(pictures: from(p in Picture, order_by: p.inserted_at))}
  end

  defp update_pro_experiences(champion, attrs) do
    received_pro_experience_ids = get_received_ids(attrs)

    # delete removed pro_experiences
    champion.pro_experiences
    |> Enum.map(fn m ->
      if !Enum.member?(received_pro_experience_ids, m.id) do
        ProExperiences.delete_pro_experience(m)
      end
    end)

    # add or update other pro_experiences
    attrs
    |> Enum.map(fn p ->
      if p.id == "new" do
        ProExperiences.create_pro_experience(champion, p)
      else
        p.id
        |> ProExperiences.get_pro_experience!()
        |> ProExperiences.update_pro_experience(p)
      end
    end)
  end

  defp do_update_medals(champion, attrs) do
    received_medal_ids = get_received_ids(attrs)
    # delete removed medals
    champion.medals
    |> Enum.map(fn m ->
      if !Enum.member?(received_medal_ids, m.id) do
        Medals.delete_medal(m)
      end
    end)

    # add or update other medals
    attrs
    |> Enum.map(fn m ->
      if m.id == "new" do
        Medals.create_medal(champion, m)
      else
        m.id
        |> Medals.get_medal!()
        |> Medals.update_medal(m)
      end
    end)
  end

  defp get_received_ids(attrs) do
    attrs
    |> Enum.reduce([], fn item, acc ->
      case Integer.parse(item.id) do
        {intId, _} ->
          [intId] ++ acc

        :error ->
          acc
      end
    end)
  end

  defp do_update_pictures(champion, attrs) do
    received_picture_ids = get_received_ids(attrs)

    # delete removed pictures
    champion.pictures
    |> Enum.map(fn p ->
      if !Enum.member?(received_picture_ids, p.id) do
        Pictures.delete_picture(champion, p)
      end
    end)

    # add or update other medals
    attrs
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
  end

  defp update_profile_picture(champion, profile_picture_attrs) do
    Logger.info("Uploading profile picture for champion #{champion.id}")
    %{filename: filename, base64: base64} = profile_picture_attrs
    file = UploadUtils.data_url_to_upload(base64)
    extension = Path.extname(filename)
    new_filename = "#{champion.id}-profile#{extension}"

    UploadUtils.copy_file_to_dest(file, new_filename, @upload_dir)

    champion
    |> Ecto.Changeset.change(%{profile_picture_filename: new_filename})
    |> Repo.update()
  end

  @doc """
  Deletes a Champion.
  """
  def delete_champion(%Champion{} = champion) do
    Repo.delete(champion)
  end

  defp generate_next_login() do
    next_login =
      case Repo.one(from(c in Champion, select: max(c.login))) do
        nil ->
          1

        val ->
          val + 1
      end

    Logger.info("Generated next login: #{next_login}")

    next_login
  end

  def get_champion_with_login(%{last_name: last_name, login_id: login_id}) do
    Logger.info("Checking if login info matches a champion")

    # last_name_formatted =
    Repo.one(
      from(c in Champion,
        where:
          c.login == ^login_id and
            fragment("lower(?)", c.last_name) == ^String.downcase(last_name)
      )
    )
  end
end
