defmodule Aisf.RecordsTest do
  use Aisf.DataCase

  alias Aisf.Records

  describe "records" do
    alias Aisf.Records.Record

    @valid_attrs %{place: "some place", record_type: 42, specialty: "some specialty", year: 42}
    @update_attrs %{place: "some updated place", record_type: 43, specialty: "some updated specialty", year: 43}
    @invalid_attrs %{place: nil, record_type: nil, specialty: nil, year: nil}

    def record_fixture(attrs \\ %{}) do
      {:ok, record} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Records.create_record()

      record
    end

    test "list_records/0 returns all records" do
      record = record_fixture()
      assert Records.list_records() == [record]
    end

    test "get_record!/1 returns the record with given id" do
      record = record_fixture()
      assert Records.get_record!(record.id) == record
    end

    test "create_record/1 with valid data creates a record" do
      assert {:ok, %Record{} = record} = Records.create_record(@valid_attrs)
      assert record.place == "some place"
      assert record.record_type == 42
      assert record.specialty == "some specialty"
      assert record.year == 42
    end

    test "create_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Records.create_record(@invalid_attrs)
    end

    test "update_record/2 with valid data updates the record" do
      record = record_fixture()
      assert {:ok, %Record{} = record} = Records.update_record(record, @update_attrs)
      assert record.place == "some updated place"
      assert record.record_type == 43
      assert record.specialty == "some updated specialty"
      assert record.year == 43
    end

    test "update_record/2 with invalid data returns error changeset" do
      record = record_fixture()
      assert {:error, %Ecto.Changeset{}} = Records.update_record(record, @invalid_attrs)
      assert record == Records.get_record!(record.id)
    end

    test "delete_record/1 deletes the record" do
      record = record_fixture()
      assert {:ok, %Record{}} = Records.delete_record(record)
      assert_raise Ecto.NoResultsError, fn -> Records.get_record!(record.id) end
    end

    test "change_record/1 returns a record changeset" do
      record = record_fixture()
      assert %Ecto.Changeset{} = Records.change_record(record)
    end
  end
end
