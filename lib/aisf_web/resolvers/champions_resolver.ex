defmodule AisfWeb.ChampionsResolver do
  alias Aisf.Champions

  require Logger

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

  def update(args, _info) do
    case Champions.get_champion(args.id) do
      nil ->
        {:error, "Champion with id #{args.id} not found! Not updating."}

      champion ->
        Champions.update_champion(champion, args)
    end
  end

  def login(args, _info) do
    case Champions.get_champion_with_login(args) do
      nil ->
        Logger.warn("No champion found for args #{inspect(args)}")
        {:ok, %{result: false}}

      champion ->
        Logger.info("Logging champion #{champion.id}")
        {:ok, %{result: true, id: champion.id}}
    end
  end
end
