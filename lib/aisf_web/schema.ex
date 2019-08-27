defmodule AisfWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: App.Repo

  alias AisfWeb.ChampionsResolver

  # alias AisfWeb.ChampionsResolver

  object :champion do
    field(:id, non_null(:id))
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
    field(:email, non_null(:string))
    # field(:sport, :sport, resolve: assoc(:sport))

    field :sport, :sport do
      resolve(fn champion, _, _ ->
        batch({AisfWeb.Schema, :by_id, Champion}, champion.sport_id, fn batch_results ->
          {:ok, Map.get(batch_results, champion.sport_id)}
        end)
      end)
    end

    # field :sport, :sport do
    #   resolve(fn champion, _, _ ->
    #     if champion.sport do
    #       {:ok, champion.sport.name}
    #     else
    #       {:error, "bla"}
    #     end
    #   end)
    # end
  end

  object :sport do
    field(:name, non_null(:string))
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

  def by_id(model, ids) do
    import Ecto.Query
    alias Aisf.Champions.Champions

    ids = ids |> Enum.uniq()

    model
    |> where([m], m.id in ^ids)
    |> Repo.all()
    |> Map.new(&{&1.id, &1})
  end
end
