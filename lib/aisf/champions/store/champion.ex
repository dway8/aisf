defmodule Aisf.Champions.Store.Champion do
  @moduledoc false

  defstruct [
    :id,
    :first_name,
    :last_name,
    :email,
    :birth_date,
    :address,
    :phone_number,
    :website,
    :sport,
    :pro_experiences,
    :years_in_french_team,
    :medals,
    :is_member,
    :intro,
    :highlights,
    :profile_picture_filename,
    :french_team_participation,
    :olympic_games_participation,
    :world_cup_participation,
    :track_record,
    :best_memory,
    :decoration,
    :background,
    :volunteering,
    :login,
    :pictures
  ]

  @type pro_experience :: %{
          company_name: String.t(),
          contact: String.t(),
          description: String.t(),
          title: String.t(),
          website: String.t()
        }

  @type medal :: %{
          competition: String.t(),
          medal_type: integer(),
          specialty: String.t(),
          year: integer()
        }

  @type picture :: %{
          filename: String.t()
        }

  @type t :: %__MODULE__{
          id: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          birth_date: String.t(),
          address: String.t(),
          phone_number: String.t(),
          website: String.t(),
          sport: String.t(),
          pro_experiences: [pro_experience],
          years_in_french_team: [integer()],
          medals: [medal],
          is_member: boolean(),
          intro: String.t(),
          highlights: [String.t()],
          profile_picture_filename: String.t(),
          french_team_participation: String.t(),
          olympic_games_participation: String.t(),
          world_cup_participation: String.t(),
          track_record: String.t(),
          best_memory: String.t(),
          decoration: String.t(),
          background: String.t(),
          volunteering: String.t(),
          login: integer(),
          pictures: [picture]
        }
end
