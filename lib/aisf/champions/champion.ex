defmodule Aisf.Champions.Champion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Aisf.ProExperiences.ProExperience
  alias Aisf.Medals.Medal

  schema "champions" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string)
    field(:sport, :string)
    has_many(:pro_experiences, ProExperience)
    field(:years_in_french_team, {:array, :integer})
    has_many(:medals, Medal)
    field(:is_member, :boolean)
    field(:intro, :string)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :first_name,
      :last_name,
      :email,
      :password,
      :sport,
      :years_in_french_team,
      :is_member,
      :intro
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :email,
      :password,
      :sport,
      :years_in_french_team,
      :is_member,
      :intro
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
