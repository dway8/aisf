defmodule Aisf.Champions do
  @moduledoc """
  The Champions context.
  """

  alias Aisf.Champions.Store

  @doc false
  defdelegate child_spec(opts), to: __MODULE__.Supervisor

  def list_champions_lite do
    Store.list_champions_lite()
  end

  def get_champion(id) do
    Store.get_champion(id)
  end

  def create_champion(args) do
    Store.create_champion(args)
  end
end
