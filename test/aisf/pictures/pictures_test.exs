defmodule Aisf.PicturesTest do
  use Aisf.DataCase

  alias Aisf.Pictures

  describe "pictures" do
    alias Aisf.Pictures.Picture

    @valid_attrs %{filename: "some filename"}
    @update_attrs %{filename: "some updated filename"}
    @invalid_attrs %{filename: nil}

    def picture_fixture(attrs \\ %{}) do
      {:ok, picture} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Pictures.create_picture()

      picture
    end

    test "list_pictures/0 returns all pictures" do
      picture = picture_fixture()
      assert Pictures.list_pictures() == [picture]
    end

    test "get_picture!/1 returns the picture with given id" do
      picture = picture_fixture()
      assert Pictures.get_picture!(picture.id) == picture
    end

    test "create_picture/1 with valid data creates a picture" do
      assert {:ok, %Picture{} = picture} = Pictures.create_picture(@valid_attrs)
      assert picture.filename == "some filename"
    end

    test "create_picture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pictures.create_picture(@invalid_attrs)
    end

    test "update_picture/2 with valid data updates the picture" do
      picture = picture_fixture()
      assert {:ok, %Picture{} = picture} = Pictures.update_picture(picture, @update_attrs)
      assert picture.filename == "some updated filename"
    end

    test "update_picture/2 with invalid data returns error changeset" do
      picture = picture_fixture()
      assert {:error, %Ecto.Changeset{}} = Pictures.update_picture(picture, @invalid_attrs)
      assert picture == Pictures.get_picture!(picture.id)
    end

    test "delete_picture/1 deletes the picture" do
      picture = picture_fixture()
      assert {:ok, %Picture{}} = Pictures.delete_picture(picture)
      assert_raise Ecto.NoResultsError, fn -> Pictures.get_picture!(picture.id) end
    end

    test "change_picture/1 returns a picture changeset" do
      picture = picture_fixture()
      assert %Ecto.Changeset{} = Pictures.change_picture(picture)
    end
  end
end
