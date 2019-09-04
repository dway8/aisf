defmodule AisfWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: App.Repo

  alias AisfWeb.ChampionsResolver

  object :champion do
    field(:id, non_null(:id))
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
    field(:email, non_null(:string))
    field(:sport, non_null(:sport), resolve: assoc(:sport))
    field(:pro_experiences, non_null(list_of(non_null(:pro_experience))))
  end

  object :sport do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
  end

  object :pro_experience do
    field(:company_name, non_null(:string))
    field(:contact, non_null(:string))
    field(:description, non_null(:string))
    field(:occupational_category, non_null(:string))
    field(:title, non_null(:string))
    field(:website, non_null(:string))
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
      arg(:sport, non_null(:string))
      arg(:pro_experiences, non_null(list_of(non_null(:pro_experience_params))))

      resolve(&ChampionsResolver.create/2)
    end
  end

  input_object :pro_experience_params do
    field(:company_name, non_null(:string))
    field(:contact, non_null(:string))
    field(:description, non_null(:string))
    field(:occupational_category, non_null(:string))
    field(:title, non_null(:string))
    field(:website, non_null(:string))
  end
end
