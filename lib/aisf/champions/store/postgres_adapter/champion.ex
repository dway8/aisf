defmodule Aisf.Champions.Store.PostgresAdapter.Champion do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Aisf.Champions.Store.PostgresAdapter.{ProExperience, Medal, Picture}

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

  # @type t :: %__MODULE__{
  #         id: String.t(),
  #         first_name: String.t(),
  #         last_name: String.t(),
  #         email: String.t(),
  #         birth_date: String.t(),
  #         address: String.t(),
  #         phone_number: String.t(),
  #         website: String.t(),
  #         sport: String.t(),
  #         years_in_french_team: [integer()],
  #         is_member: boolean(),
  #         intro: String.t(),
  #         highlights: [String.t()],
  #         profile_picture_filename: String.t(),
  #         french_team_participation: String.t(),
  #         olympic_games_participation: String.t(),
  #         world_cup_participation: String.t(),
  #         track_record: String.t(),
  #         best_memory: String.t(),
  #         decoration: String.t(),
  #         background: String.t(),
  #         volunteering: String.t(),
  #         login: integer()
  #       }

  def changeset(champion, params) do
    champion
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
end
