defmodule AisfWeb.ChampionsResolver do
  alias Aisf.Champions

  def all(_root, _args, _info) do
    champions = Champions.list_champions()
    {:ok, champions}
  end

  def get_members(_root, _args, _info) do
    champions = Champions.list_members()
    {:ok, champions}
  end

  def get(%{id: id}, _info) do
    case Champions.get_champion(id) do
      nil -> {:error, "Champion with id #{id} not found!"}
      champion -> {:ok, champion}
    end
  end

  def get_by_medal_in_sport(%{sport: sport}, _info) do
    champions = Champions.list_champions_with_medal_in_sport(sport)
    {:ok, champions}
  end

  def create(args, _info) do
    Champions.create_champion(args)
  end
end
