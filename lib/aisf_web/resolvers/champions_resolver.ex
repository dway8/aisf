defmodule AisfWeb.ChampionsResolver do
  alias Aisf.Champions

  def all_champions(_root, _args, _info) do
    champions = Champions.list_champions()
    {:ok, champions}
  end
end
