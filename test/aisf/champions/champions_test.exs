defmodule Aisf.ChampionsTest do
  use Aisf.DataCase

  alias Aisf.Champions

  describe "champions" do
    alias Aisf.Champions.Champion

    @valid_attrs %{first_name: "some first_name", last_name: "some last_name"}
    @update_attrs %{first_name: "some updated first_name", last_name: "some updated last_name"}
    @invalid_attrs %{first_name: nil, last_name: nil}

    def champion_fixture(attrs \\ %{}) do
      {:ok, champion} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Champions.create_champion()

      champion
    end

    test "list_champions/0 returns all champions" do
      champion = champion_fixture()
      assert Champions.list_champions() == [champion]
    end

    test "get_champion!/1 returns the champion with given id" do
      champion = champion_fixture()
      assert Champions.get_champion!(champion.id) == champion
    end

    test "create_champion/1 with valid data creates a champion" do
      assert {:ok, %Champion{} = champion} = Champions.create_champion(@valid_attrs)
      assert champion.first_name == "some first_name"
      assert champion.last_name == "some last_name"
    end

    test "create_champion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Champions.create_champion(@invalid_attrs)
    end

    test "update_champion/2 with valid data updates the champion" do
      champion = champion_fixture()
      assert {:ok, %Champion{} = champion} = Champions.update_champion(champion, @update_attrs)
      assert champion.first_name == "some updated first_name"
      assert champion.last_name == "some updated last_name"
    end

    test "update_champion/2 with invalid data returns error changeset" do
      champion = champion_fixture()
      assert {:error, %Ecto.Changeset{}} = Champions.update_champion(champion, @invalid_attrs)
      assert champion == Champions.get_champion!(champion.id)
    end

    test "delete_champion/1 deletes the champion" do
      champion = champion_fixture()
      assert {:ok, %Champion{}} = Champions.delete_champion(champion)
      assert_raise Ecto.NoResultsError, fn -> Champions.get_champion!(champion.id) end
    end

    test "change_champion/1 returns a champion changeset" do
      champion = champion_fixture()
      assert %Ecto.Changeset{} = Champions.change_champion(champion)
    end
  end
end
