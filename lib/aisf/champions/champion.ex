defmodule Aisf.Champions.Champion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Aisf.Sport
  alias Aisf.ProExperiences.ProExperience
  alias Aisf.Medals.Medal

  schema "champions" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string)
    belongs_to(:sport, Sport)
    has_many(:pro_experiences, ProExperience)
    field(:years_in_french_team, {:array, :integer})
    has_many(:medals, Medal)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :first_name,
      :last_name,
      :email,
      :password,
      :sport_id,
      :years_in_french_team,
      :medals
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :email,
      :password,
      :sport_id,
      :years_in_french_team,
      :medals
    ])
  end
end
