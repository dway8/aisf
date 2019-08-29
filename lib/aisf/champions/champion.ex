defmodule Aisf.Champions.Champion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Aisf.Sport

  schema "champions" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string)
    belongs_to(:sport, Sport)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:first_name, :last_name, :email, :password, :sport_id])
    |> validate_required([:first_name, :last_name, :email, :password, :sport_id])
  end
end
