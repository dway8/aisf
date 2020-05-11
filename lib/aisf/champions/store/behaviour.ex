defmodule Aisf.Champions.Store.Behaviour do
  @moduledoc false

  alias Aisf.Champions.Store.Champion

  @callback list_champions_lite() :: [Champion.t()]

  @callback get_champion(id :: String.t()) :: {:ok, Champion.t()} | {:error, :not_found}

  @callback create_champion(map) ::
              {:ok, Champion.t()} | {:error, :missing_fields}

  @callback generate_next_login() :: integer()
end
