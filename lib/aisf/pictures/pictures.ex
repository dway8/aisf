defmodule Aisf.Pictures.Pictures do
  @moduledoc """
  The Pictures context.
  """
  import Ecto.Query, warn: false
  require Logger
  alias Aisf.Repo
  alias Aisf.Pictures.Picture
  alias Aisf.UploadUtils

  @upload_dir Application.get_env(:aisf, AisfWeb.Endpoint)[:upload_dir]

  @doc """
  Returns the list of pictures.
  """
  def list_pictures do
    Repo.all(Picture)
  end

  @doc """
  Gets a single picture.

  Raises `Ecto.NoResultsError` if the Picture does not exist.


  """
  def get_picture!(id), do: Repo.get!(Picture, id)

  @doc """
  Creates a picture.

  """
  def create_picture(champion, attrs \\ %{}) do
    Logger.info("Adding a picture for champion #{champion.id}")
    %{filename: filename, base64: base64} = attrs.attachment

    case champion
         |> Ecto.build_assoc(:pictures)
         |> Picture.changeset(attrs.attachment)
         |> Repo.insert() do
      {:ok, _picture} ->
        file = UploadUtils.data_url_to_upload(base64)

        upload_dir = "#{@upload_dir}/#{champion.id}"

        UploadUtils.copy_file_to_dest(file, filename, upload_dir)

      {:error, err} ->
        Logger.error("Error when creating a picture for champion #{champion.id}: #{err}")
    end
  end

  @doc """
  Updates a picture.


  """
  def update_picture(champion, %Picture{} = picture, attrs) do
    Logger.info("Updating picture #{picture.id} of champion #{champion.id}")
    %{filename: filename, base64: base64} = attrs.attachment
    upload_dir = "#{@upload_dir}/#{champion.id}"

    UploadUtils.remove_file_at_dest(picture.filename, upload_dir)

    file = UploadUtils.data_url_to_upload(base64)
    UploadUtils.copy_file_to_dest(file, filename, upload_dir)

    picture
    |> Picture.changeset(attrs.attachment)
    |> Repo.update()
  end

  @doc """
  Deletes a Picture.


  """
  def delete_picture(champion, %Picture{} = picture) do
    Logger.info("Removing picture #{picture.id} of champion #{champion.id}")

    Repo.delete(picture)

    upload_dir = "#{@upload_dir}/#{champion.id}"
    UploadUtils.remove_file_at_dest(picture.filename, upload_dir)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking picture changes.

  """
  def change_picture(%Picture{} = picture) do
    Picture.changeset(picture, %{})
  end
end
