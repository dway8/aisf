defmodule Aisf.Champions do
  @moduledoc """
  The Champions context.
  """
  require Logger

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
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload(:medals)
  end

  @doc """
  Returns the list of members.
  """
  def list_members do
    Repo.all(from(c in Champion, where: c.is_member == true))
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload(:medals)
  end

  @doc """
  Returns the list of champions with medals.
  """
  def list_champions_with_medals do
    Repo.all(
      from(c in Champion, join: m in Medal, on: m.champion_id == c.id, group_by: c.id, select: c)
    )
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload(:medals)
  end

  @doc """
  Gets a single champion.

  Raises `Ecto.NoResultsError` if the Champion does not exist.
  """
  def get_champion!(id) do
    Repo.get!(Champion, id)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload(:medals)
  end

  @doc """
  Gets a single champion.
  """
  def get_champion(id) do
    Repo.get(Champion, id)
    |> Repo.preload(pro_experiences: [:sectors])
    |> Repo.preload(:medals)
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
           |> Repo.preload(:medals)}
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
        file = data_url_to_upload(base64)
        extension = Path.extname(filename)
        new_filename = "#{champion.id}-profile#{extension}"

        upload_dir = Application.get_env(:aisf, AisfWeb.Endpoint)[:upload_dir]
        Logger.info("Upload directory: #{upload_dir}")
        File.mkdir_p(upload_dir)
        File.cp(file.path, "#{upload_dir}/#{new_filename}")

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

          {:ok,
           champion
           |> Repo.preload(pro_experiences: [:sectors])
           |> Repo.preload(:medals)}
        end).()
  end

  defp data_url_to_upload(data_url) do
    with %{scheme: "data"} = uri <- URI.parse(data_url),
         %URL.Data{data: data} <- URL.Data.parse(uri) do
      binary_to_upload(data)
    end
  end

  defp binary_to_upload(binary) do
    with {:ok, path} <- Plug.Upload.random_file("upload"),
         {:ok, file} <- File.open(path, [:write, :binary]),
         :ok <- IO.binwrite(file, binary),
         :ok <- File.close(file) do
      %Plug.Upload{path: path}
    end
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
