defmodule AisfWeb.EventsResolver do
  alias Aisf.Events.Events

  def all(_root, _args, _info) do
    events = Events.list_events()
    {:ok, events}
  end

  def create(args, _info) do
    Events.create_event(args)
  end
end
