defmodule AisfWeb.Schema do
  use Absinthe.Schema

  alias AisfWeb.ChampionsResolver

  # alias AisfWeb.ChampionsResolver

  object :champion do
    field(:id, non_null(:id))
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
  end

  query do
    field :all_champions, non_null(list_of(non_null(:champion))) do
      resolve(&ChampionsResolver.all_champions/3)
    end
  end
end
