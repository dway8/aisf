defmodule Aisf.Records.Records do
  @moduledoc """
  The Records context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Records.{Record, Winner}

  @doc """
  Returns the list of records.
  """
  def list_records do
    Repo.all(Record)
    |> Repo.preload([:winners])
  end

  @doc """
  Gets a single record.

  Raises `Ecto.NoResultsError` if the Record does not exist.
  """
  def get_record!(id), do: Repo.get!(Record, id)

  @doc """
  Creates a record.
  """
  def create_record(attrs \\ %{}) do
    %Record{}
    |> Record.changeset(attrs)
    |> Repo.insert()
    |> (fn {:ok, record} ->
          Logger.info("Creating record OK with id #{record.id}")

          attrs.winners
          |> Enum.map(fn w -> create_winner(record, w) end)

          {:ok, record |> Repo.preload([:winners])}
        end).()
  end

  defp create_winner(record, attrs) do
    Logger.info("Creating winner for record #{record.id}")

    record
    |> Ecto.build_assoc(:winners)
    |> Winner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a record.
  """
  def update_record(%Record{} = record, attrs) do
    record
    |> Record.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Record.
  """
  def delete_record(%Record{} = record) do
    Repo.delete(record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking record changes.
  """
  def change_record(%Record{} = record) do
    Record.changeset(record, %{})
  end
end
