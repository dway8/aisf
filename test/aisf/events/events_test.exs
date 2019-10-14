defmodule Aisf.EventsTest do
  use Aisf.DataCase

  alias Aisf.Events

  describe "events" do
    alias Aisf.Events.Event

    @valid_attrs %{competition: "some competition", place: "some place", sport: "some sport", year: 42}
    @update_attrs %{competition: "some updated competition", place: "some updated place", sport: "some updated sport", year: 43}
    @invalid_attrs %{competition: nil, place: nil, sport: nil, year: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Events.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Events.create_event(@valid_attrs)
      assert event.competition == "some competition"
      assert event.place == "some place"
      assert event.sport == "some sport"
      assert event.year == 42
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, %Event{} = event} = Events.update_event(event, @update_attrs)
      assert event.competition == "some updated competition"
      assert event.place == "some updated place"
      assert event.sport == "some updated sport"
      assert event.year == 43
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
