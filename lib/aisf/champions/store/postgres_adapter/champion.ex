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
  #         id: String.t() | nil,
  #         email: String.t() | nil,
  #         password: String.t() | nil,
  #         password_hash: String.t() | nil,
  #         inserted_at: DateTime.t() | nil,
  #         updated_at: DateTime.t() | nil
  #       }

  # @spec changeset(t, map) :: Changeset.t()
  # def changeset(user, attrs) do
  #   user
  #   |> cast(attrs, [:email, :password])
  #   |> validate_required([:email, :password])
  #   |> unique_constraint(:email, message: "is_already_registered")
  #   |> put_password_hash()
  # end
end
