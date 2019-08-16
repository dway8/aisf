defmodule AisfWeb.ChampionsResolver do
  alias Aisf.Champions

  def all(_root, _args, _info) do
    champions = Champions.list_champions()
    {:ok, champions}
  end

  def get(%{id: id}, _info) do
    case Champions.get_champion(id) do
      nil -> {:error, "Champion with id #{id} not found!"}
      champion -> {:ok, champion}
    end
  end

  def create(args, _info) do
    Champions.create_champion(args)
  end
end
