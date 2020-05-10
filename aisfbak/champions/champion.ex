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
      :sport,
      :is_member,
      :login
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :sport,
      :is_member,
      :login
    ])
  end

  def presentation_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :first_name,
      :last_name,
      :sport,
      :is_member,
      :intro,
      :highlights,
      :profile_picture_filename
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :sport,
      :is_member,
      :highlights
    ])
  end

  def private_info_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :email,
      :birth_date,
      :address,
      :phone_number
    ])
  end

  def sport_career_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :olympic_games_participation,
      :world_cup_participation,
      :track_record,
      :best_memory,
      :decoration,
      :years_in_french_team
    ])
    |> validate_required([:years_in_french_team])
  end

  def professional_career_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:background, :volunteering, :pro_experiences])
    |> validate_required([:pro_experiences])
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
