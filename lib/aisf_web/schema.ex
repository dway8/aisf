defmodule AisfWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: App.Repo

  alias AisfWeb.ChampionsResolver

  object :champion do
    field(:id, non_null(:id))
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
    field(:email, :string)
    field(:birth_date, :string)
    field(:address, :string)
    field(:phone_number, :string)
    field(:website, :string)
    field(:sport, non_null(:string))
    field(:pro_experiences, non_null(list_of(non_null(:pro_experience))))
    field(:years_in_french_team, list_of(non_null(:integer)))
    field(:medals, non_null(list_of(non_null(:medal))))
    field(:is_member, non_null(:boolean))
    field(:intro, :string)
    field(:highlights, list_of(non_null(:string)))
    field(:profile_picture_filename, :string)
    field(:french_team_participation, :string)
    field(:olympic_games_participation, :string)
    field(:world_cup_participation, :string)
    field(:track_record, :string)
    field(:best_memory, :string)
    field(:decoration, :string)
    field(:background, :string)
    field(:volunteering, :string)
    field(:old_id, :integer)
  end

  object :pro_experience do
    field(:id, non_null(:id))
    field(:company_name, non_null(:string))
    field(:contact, non_null(:string))
    field(:description, non_null(:string))
    field(:occupational_category, non_null(:string))
    field(:title, non_null(:string))
    field(:website, non_null(:string))
  end

  object :medal do
    field(:id, non_null(:id))
    field(:competition, non_null(:string))
    field(:year, non_null(:integer))
    field(:specialty, non_null(:string))
    field(:medal_type, non_null(:integer))
  end

  query do
    field :all_champions, non_null(list_of(non_null(:champion))) do
      resolve(&ChampionsResolver.all/3)
    end

    field :get_members, non_null(list_of(non_null(:champion))) do
      resolve(&ChampionsResolver.get_members/3)
    end

    field :champion, non_null(:champion) do
      arg(:id, non_null(:id))
      resolve(&ChampionsResolver.get/2)
    end

    field :champions_with_medals, non_null(list_of(non_null(:champion))) do
      resolve(&ChampionsResolver.get_with_medals/2)
    end
  end

  mutation do
    field :create_champion, type: :champion do
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:email, :string)
      arg(:sport, non_null(:string))
      arg(:pro_experiences, non_null(list_of(non_null(:pro_experience_params))))
      arg(:years_in_french_team, non_null(list_of(non_null(:integer))))
      arg(:medals, non_null(list_of(non_null(:medal_params))))
      arg(:is_member, non_null(:boolean))
      arg(:intro, :string)
      arg(:french_team_participation, :string)
      arg(:olympic_games_participation, :string)
      arg(:world_cup_participation, :string)
      arg(:track_record, :string)
      arg(:best_memory, :string)
      arg(:decoration, :string)
      arg(:background, :string)
      arg(:volunteering, :string)

      resolve(&ChampionsResolver.create/2)
    end

    field :update_champion, type: :champion do
      arg(:id, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:email, :string)
      arg(:sport, non_null(:string))
      arg(:pro_experiences, non_null(list_of(non_null(:pro_experience_params))))
      arg(:years_in_french_team, non_null(list_of(non_null(:integer))))
      arg(:medals, non_null(list_of(non_null(:medal_params))))
      arg(:is_member, non_null(:boolean))
      arg(:intro, :string)
      arg(:profile_picture, :file_params)
      arg(:french_team_participation, :string)
      arg(:olympic_games_participation, :string)
      arg(:world_cup_participation, :string)
      arg(:track_record, :string)
      arg(:best_memory, :string)
      arg(:decoration, :string)
      arg(:background, :string)
      arg(:volunteering, :string)

      resolve(&ChampionsResolver.update/2)
    end
  end

  input_object :pro_experience_params do
    field(:id, non_null(:string))
    field(:company_name, non_null(:string))
    field(:contact, non_null(:string))
    field(:description, non_null(:string))
    field(:occupational_category, non_null(:string))
    field(:title, non_null(:string))
    field(:website, non_null(:string))
  end

  input_object :medal_params do
    field(:id, non_null(:string))
    field(:competition, non_null(:string))
    field(:year, non_null(:integer))
    field(:specialty, non_null(:string))
    field(:medal_type, non_null(:integer))
  end

  input_object :file_params do
    field(:filename, non_null(:string))
    field(:base64, :string)
  end
end
