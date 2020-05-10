defmodule Aisf.Events.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Aisf.Repo

  alias Aisf.Events.Event

  @doc """
  Returns the list of events.
  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.
  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.
  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Event.
  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.
  """
  def change_event(%Event{} = event) do
    Event.changeset(event, %{})
  end
end
