defmodule Aisf.Champions.Store do
  @moduledoc """
  The Champions context.
  """

  @doc false
  defdelegate child_spec(opts), to: __MODULE__.Supervisor

  @adapter Application.get_env(:aisf, :champions, __MODULE__.PostgresAdapter)

  def list_champions_lite do
    @adapter.list_champions_lite()
  end

  def get_champion(id) do
    @adapter.get_champion(id)
  end
end
