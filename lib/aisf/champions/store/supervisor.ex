defmodule Aisf.Champions.Store.Supervisor do
  @moduledoc false
  use Supervisor

  alias Aisf.Champions.Store.PostgresAdapter

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {PostgresAdapter, name: PostgresAdapter}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

