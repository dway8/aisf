defmodule Aisf.Champions.Champion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Aisf.ProExperiences.ProExperience
  alias Aisf.Medals.Medal
  alias Aisf.Pictures.Picture

  schema "champions" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:birth_date, :string)
    field(:address, :string)
    field(:phone_number, :string)
    field(:website, :string)
    field(:sport, :string)
    has_many(:pro_experiences, ProExperience)
    field(:years_in_french_team, {:array, :integer})
    has_many(:medals, Medal)
    field(:is_member, :boolean)
    field(:intro, :string)
    field(:highlights, {:array, :string})
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
    has_many(:pictures, Picture)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :first_name,
      :last_name,
      :email,
      :birth_date,
      :address,
      :phone_number,
      :website,
      :sport,
      :years_in_french_team,
      :is_member,
      :intro,
      :profile_picture_filename,
      :olympic_games_participation,
      :world_cup_participation,
      :track_record,
      :best_memory,
      :decoration,
      :background,
      :volunteering,
      :highlights,
      :login
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :sport,
      :years_in_french_team,
      :is_member,
      :highlights,
      :login
    ])
  end

  def sports do
    [
      "Ski alpin",
      "Ski de fond",
      "Biathlon",
      "Combiné nordique",
      "Freestyle",
      "Saut",
      "Snowboard"
    ]
  end
end
