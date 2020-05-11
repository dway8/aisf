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

  def create_champion(args) do
    args =
      args
      |> Map.put(:login, generate_next_login())

    @adapter.create_champion(args)
  end

  defp generate_next_login() do
    @adapter.generate_next_login()
  end
end
