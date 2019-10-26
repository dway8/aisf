defmodule AisfWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: App.Repo

  alias AisfWeb.{ChampionsResolver, SectorsResolver, EventsResolver, RecordsResolver}

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
    field(:login, :integer)
    field(:pictures, non_null(list_of(non_null(:picture))))
  end

  object :picture do
    field(:id, non_null(:id))
    field(:filename, non_null(:string))
  end

  object :pro_experience do
    field(:id, non_null(:id))
    field(:company_name, :string)
    field(:contact, :string)
    field(:description, :string)
    field(:sectors, non_null(list_of(non_null(:sector))))
    field(:title, :string)
    field(:website, :string)
  end

  object :medal do
    field(:id, non_null(:id))
    field(:competition, non_null(:string))
    field(:year, non_null(:integer))
    field(:specialty, non_null(:string))
    field(:medal_type, non_null(:integer))
  end

  object :sector do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
  end

  object :event do
    field(:competition, non_null(:string))
    field(:sport, :string)
    field(:year, non_null(:integer))
    field(:place, non_null(:string))
  end

  object :record do
    field(:record_type, non_null(:integer))
    field(:year, non_null(:integer))
    field(:place, non_null(:string))
    field(:specialty, non_null(:string))
    field(:winners, non_null(list_of(non_null(:winner))))
  end

  object :winner do
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
    field(:position, non_null(:integer))
  end

  object :login_response do
    field(:result, non_null(:boolean))
    field(:id, :id)
  end

  query do
    field :champions, non_null(list_of(non_null(:champion))) do
      resolve(&ChampionsResolver.all/3)
    end

    field :champion, non_null(:champion) do
      arg(:id, non_null(:id))
      resolve(&ChampionsResolver.get/2)
    end

    field :sectors, non_null(list_of(non_null(:sector))) do
      resolve(&SectorsResolver.all/3)
    end

    field :events, non_null(list_of(non_null(:event))) do
      resolve(&EventsResolver.all/3)
    end

    field :records, non_null(list_of(non_null(:record))) do
      resolve(&RecordsResolver.all/3)
    end

    field :login, non_null(:login_response) do
      arg(:last_name, non_null(:string))
      arg(:login_id, non_null(:string))
      resolve(&ChampionsResolver.login/2)
    end
  end

  mutation do
    field :create_champion, type: :champion do
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
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
      arg(:highlights, non_null(list_of(non_null(:string))))
      arg(:pictures, non_null(list_of(non_null(:picture_params))))
      arg(:birth_date, :string)
      arg(:address, :string)
      arg(:email, :string)
      arg(:phone_number, :string)
      arg(:profile_picture, :file_params)

      resolve(&ChampionsResolver.create/2)
    end

    field :update_champion, type: :champion do
      arg(:id, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
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
      arg(:highlights, non_null(list_of(non_null(:string))))
      arg(:pictures, non_null(list_of(non_null(:picture_params))))
      arg(:birth_date, :string)
      arg(:address, :string)
      arg(:email, :string)
      arg(:phone_number, :string)

      resolve(&ChampionsResolver.update/2)
    end

    field :create_event, type: non_null(:event) do
      arg(:competition, non_null(:string))
      arg(:sport, :string)
      arg(:year, non_null(:integer))
      arg(:place, non_null(:string))
      resolve(&EventsResolver.create/2)
    end

    field :create_record, type: non_null(:record) do
      arg(:record_type, non_null(:integer))
      arg(:year, non_null(:integer))
      arg(:place, non_null(:string))
      arg(:specialty, non_null(:string))
      arg(:winners, non_null(list_of(non_null(:winner_params))))
      resolve(&RecordsResolver.create/2)
    end
  end

  input_object :pro_experience_params do
    field(:id, non_null(:string))
    field(:company_name, :string)
    field(:contact, :string)
    field(:description, :string)
    field(:title, :string)
    field(:website, :string)
    field(:sectors, non_null(list_of(non_null(:string))))
  end

  input_object :medal_params do
    field(:id, non_null(:string))
    field(:competition, non_null(:string))
    field(:year, non_null(:integer))
    field(:specialty, non_null(:string))
    field(:medal_type, non_null(:integer))
  end

  input_object :picture_params do
    field(:id, non_null(:string))
    field(:attachment, non_null(:file_params))
  end

  input_object :file_params do
    field(:filename, non_null(:string))
    field(:base64, :string)
  end

  input_object :winner_params do
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
    field(:position, non_null(:integer))
  end
end
