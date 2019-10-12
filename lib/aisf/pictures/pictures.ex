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
    %{filename: filename, base64: base64} = attrs.attachment

    case champion
         |> Ecto.build_assoc(:pictures)
         |> Picture.changeset(attrs.attachment)
         |> Repo.insert() do
      {:ok, picture} ->
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
  def update_picture(%Picture{} = picture, attrs) do
    picture
    |> Picture.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Picture.


  """
  def delete_picture(%Picture{} = picture) do
    Repo.delete(picture)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking picture changes.

  """
  def change_picture(%Picture{} = picture) do
    Picture.changeset(picture, %{})
  end
end
