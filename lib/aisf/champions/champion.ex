defmodule Aisf.Champions.Champion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "champions" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:first_name, :last_name, :email])
    |> validate_required([:first_name, :last_name, :email])
    |> add_pass_hash()
  end

  defp add_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    password = Ecto.UUID.generate() |> binary_part(16, 16)

    change(changeset, password: Bcrypt.hashpwsalt(password))
  end

  defp add_pass_hash(changeset), do: changeset
end
