defmodule Aisf.UploadUtils do
  @moduledoc """
  Upload utils for champions pictures.
  """
  def data_url_to_upload(data_url) do
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

  def copy_file_to_dest(file, filename, dest_dir) do
    File.mkdir_p(dest_dir)
    File.cp(file.path, "#{dest_dir}/#{filename}")
  end
end
