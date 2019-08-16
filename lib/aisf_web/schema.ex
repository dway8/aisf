defmodule AisfWeb.Schema do
  use Absinthe.Schema

  alias AisfWeb.ChampionsResolver

  # alias AisfWeb.ChampionsResolver

  object :champion do
    field(:id, non_null(:id))
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
    field(:email, non_null(:string))
  end

  query do
    field :all_champions, non_null(list_of(non_null(:champion))) do
      resolve(&ChampionsResolver.all/3)
    end

    field :champion, non_null(:champion) do
      arg(:id, non_null(:id))
      resolve(&ChampionsResolver.get/2)
    end
  end

  mutation do
    field :create_champion, type: :champion do
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:email, non_null(:string))

      resolve(&ChampionsResolver.create/2)
    end
  end
end
