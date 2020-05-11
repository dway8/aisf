defmodule Aisf.Champions.Store.Behaviour do
  @moduledoc false

  alias Aisf.Champions.Store.Champion

  @callback list_champions_lite() :: [Champion.t()]

  @callback get_champion(id :: String.t()) :: {:ok, Champion.t()} | {:error, :not_found}
end
