defmodule Aisf.SectorsTest do
  use Aisf.DataCase

  alias Aisf.Sectors

  describe "sectors" do
    alias Aisf.Sectors.Sector

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def sector_fixture(attrs \\ %{}) do
      {:ok, sector} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sectors.create_sector()

      sector
    end

    test "list_sectors/0 returns all sectors" do
      sector = sector_fixture()
      assert Sectors.list_sectors() == [sector]
    end

    test "get_sector!/1 returns the sector with given id" do
      sector = sector_fixture()
      assert Sectors.get_sector!(sector.id) == sector
    end

    test "create_sector/1 with valid data creates a sector" do
      assert {:ok, %Sector{} = sector} = Sectors.create_sector(@valid_attrs)
      assert sector.name == "some name"
    end

    test "create_sector/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sectors.create_sector(@invalid_attrs)
    end

    test "update_sector/2 with valid data updates the sector" do
      sector = sector_fixture()
      assert {:ok, %Sector{} = sector} = Sectors.update_sector(sector, @update_attrs)
      assert sector.name == "some updated name"
    end

    test "update_sector/2 with invalid data returns error changeset" do
      sector = sector_fixture()
      assert {:error, %Ecto.Changeset{}} = Sectors.update_sector(sector, @invalid_attrs)
      assert sector == Sectors.get_sector!(sector.id)
    end

    test "delete_sector/1 deletes the sector" do
      sector = sector_fixture()
      assert {:ok, %Sector{}} = Sectors.delete_sector(sector)
      assert_raise Ecto.NoResultsError, fn -> Sectors.get_sector!(sector.id) end
    end

    test "change_sector/1 returns a sector changeset" do
      sector = sector_fixture()
      assert %Ecto.Changeset{} = Sectors.change_sector(sector)
    end
  end
end
