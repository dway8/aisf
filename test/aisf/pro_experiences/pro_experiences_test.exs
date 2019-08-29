defmodule Aisf.ProExperiencesTest do
  use Aisf.DataCase

  alias Aisf.ProExperiences

  describe "pro_experiences" do
    alias Aisf.ProExperiences.ProExperience

    @valid_attrs %{companyName: "some companyName", contact: "some contact", description: "some description", occupationalCategory: "some occupationalCategory", title: "some title", website: "some website"}
    @update_attrs %{companyName: "some updated companyName", contact: "some updated contact", description: "some updated description", occupationalCategory: "some updated occupationalCategory", title: "some updated title", website: "some updated website"}
    @invalid_attrs %{companyName: nil, contact: nil, description: nil, occupationalCategory: nil, title: nil, website: nil}

    def pro_experience_fixture(attrs \\ %{}) do
      {:ok, pro_experience} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ProExperiences.create_pro_experience()

      pro_experience
    end

    test "list_pro_experiences/0 returns all pro_experiences" do
      pro_experience = pro_experience_fixture()
      assert ProExperiences.list_pro_experiences() == [pro_experience]
    end

    test "get_pro_experience!/1 returns the pro_experience with given id" do
      pro_experience = pro_experience_fixture()
      assert ProExperiences.get_pro_experience!(pro_experience.id) == pro_experience
    end

    test "create_pro_experience/1 with valid data creates a pro_experience" do
      assert {:ok, %ProExperience{} = pro_experience} = ProExperiences.create_pro_experience(@valid_attrs)
      assert pro_experience.companyName == "some companyName"
      assert pro_experience.contact == "some contact"
      assert pro_experience.description == "some description"
      assert pro_experience.occupationalCategory == "some occupationalCategory"
      assert pro_experience.title == "some title"
      assert pro_experience.website == "some website"
    end

    test "create_pro_experience/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ProExperiences.create_pro_experience(@invalid_attrs)
    end

    test "update_pro_experience/2 with valid data updates the pro_experience" do
      pro_experience = pro_experience_fixture()
      assert {:ok, %ProExperience{} = pro_experience} = ProExperiences.update_pro_experience(pro_experience, @update_attrs)
      assert pro_experience.companyName == "some updated companyName"
      assert pro_experience.contact == "some updated contact"
      assert pro_experience.description == "some updated description"
      assert pro_experience.occupationalCategory == "some updated occupationalCategory"
      assert pro_experience.title == "some updated title"
      assert pro_experience.website == "some updated website"
    end

    test "update_pro_experience/2 with invalid data returns error changeset" do
      pro_experience = pro_experience_fixture()
      assert {:error, %Ecto.Changeset{}} = ProExperiences.update_pro_experience(pro_experience, @invalid_attrs)
      assert pro_experience == ProExperiences.get_pro_experience!(pro_experience.id)
    end

    test "delete_pro_experience/1 deletes the pro_experience" do
      pro_experience = pro_experience_fixture()
      assert {:ok, %ProExperience{}} = ProExperiences.delete_pro_experience(pro_experience)
      assert_raise Ecto.NoResultsError, fn -> ProExperiences.get_pro_experience!(pro_experience.id) end
    end

    test "change_pro_experience/1 returns a pro_experience changeset" do
      pro_experience = pro_experience_fixture()
      assert %Ecto.Changeset{} = ProExperiences.change_pro_experience(pro_experience)
    end
  end
end
