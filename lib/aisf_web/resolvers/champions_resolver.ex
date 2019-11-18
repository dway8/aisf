defmodule AisfWeb.ChampionsResolver do
  alias Aisf.Champions

  require Logger

  def all_lite(_root, _args, _info) do
    champions = Champions.list_champions_lite()
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

  def update_presentation(args, _info) do
    case Champions.get_champion(args.id) do
      nil ->
        {:error, "Champion with id #{args.id} not found! Not updating presentation."}

      champion ->
        Champions.update_presentation(champion, args)
    end
  end

  def update_private_info(args, _info) do
    case Champions.get_champion(args.id) do
      nil ->
        {:error, "Champion with id #{args.id} not found! Not updating private info."}

      champion ->
        Champions.update_private_info(champion, args)
    end
  end

  def update_sport_career(args, _info) do
    case Champions.get_champion(args.id) do
      nil ->
        {:error, "Champion with id #{args.id} not found! Not updating sport career."}

      champion ->
        Champions.update_sport_career(champion, args)
    end
  end

  def update_professional_career(args, _info) do
    case Champions.get_champion(args.id) do
      nil ->
        {:error, "Champion with id #{args.id} not found! Not updating professional career."}

      champion ->
        Champions.update_professional_career(champion, args)
    end
  end

  def update_pictures(args, _info) do
    case Champions.get_champion(args.id) do
      nil ->
        {:error, "Champion with id #{args.id} not found! Not updating pictures."}

      champion ->
        Champions.update_pictures(champion, args)
    end
  end

  def update_medals(args, _info) do
    case Champions.get_champion(args.id) do
      nil ->
        {:error, "Champion with id #{args.id} not found! Not updating medals."}

      champion ->
        Champions.update_medals(champion, args)
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

  def delete(%{id: id}, _info) do
    case Champions.get_champion(id) do
      nil ->
        Logger.warn("No champion found for id #{id}")
        {:ok, false}

      champion ->
        case Champions.delete_champion(champion) do
          {:ok, _} ->
            {:ok, true}

          {:error, _} ->
            {:ok, false}
        end
    end
  end
end
