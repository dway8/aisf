defmodule Aisf.MedalsTest do
  use Aisf.DataCase

  alias Aisf.Medals

  describe "medals" do
    alias Aisf.Medals.Medal

    @valid_attrs %{competition: "some competition", medal_type: 42, specialty: "some specialty", year: 42}
    @update_attrs %{competition: "some updated competition", medal_type: 43, specialty: "some updated specialty", year: 43}
    @invalid_attrs %{competition: nil, medal_type: nil, specialty: nil, year: nil}

    def medal_fixture(attrs \\ %{}) do
      {:ok, medal} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Medals.create_medal()

      medal
    end

    test "list_medals/0 returns all medals" do
      medal = medal_fixture()
      assert Medals.list_medals() == [medal]
    end

    test "get_medal!/1 returns the medal with given id" do
      medal = medal_fixture()
      assert Medals.get_medal!(medal.id) == medal
    end

    test "create_medal/1 with valid data creates a medal" do
      assert {:ok, %Medal{} = medal} = Medals.create_medal(@valid_attrs)
      assert medal.competition == "some competition"
      assert medal.medal_type == 42
      assert medal.specialty == "some specialty"
      assert medal.year == 42
    end

    test "create_medal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Medals.create_medal(@invalid_attrs)
    end

    test "update_medal/2 with valid data updates the medal" do
      medal = medal_fixture()
      assert {:ok, %Medal{} = medal} = Medals.update_medal(medal, @update_attrs)
      assert medal.competition == "some updated competition"
      assert medal.medal_type == 43
      assert medal.specialty == "some updated specialty"
      assert medal.year == 43
    end

    test "update_medal/2 with invalid data returns error changeset" do
      medal = medal_fixture()
      assert {:error, %Ecto.Changeset{}} = Medals.update_medal(medal, @invalid_attrs)
      assert medal == Medals.get_medal!(medal.id)
    end

    test "delete_medal/1 deletes the medal" do
      medal = medal_fixture()
      assert {:ok, %Medal{}} = Medals.delete_medal(medal)
      assert_raise Ecto.NoResultsError, fn -> Medals.get_medal!(medal.id) end
    end

    test "change_medal/1 returns a medal changeset" do
      medal = medal_fixture()
      assert %Ecto.Changeset{} = Medals.change_medal(medal)
    end
  end
end
