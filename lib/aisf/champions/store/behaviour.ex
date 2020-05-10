defmodule Aisf.Champions.Store.Behaviour do
  @moduledoc false

  alias Aisf.Champions.Store.Champion

  @callback list_champions_lite() :: [Champion.t()]
end
