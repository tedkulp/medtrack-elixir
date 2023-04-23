defmodule Medtrack.TrackerTest do
  use Medtrack.DataCase

  alias Medtrack.Tracker

  describe "medications" do
    alias Medtrack.Tracker.Medication

    import Medtrack.TrackerFixtures

    @invalid_attrs %{name: nil}

    test "list_medications/0 returns all medications" do
      medication = medication_fixture()
      assert Tracker.list_medications() == [medication]
    end

    test "get_medication!/1 returns the medication with given id" do
      medication = medication_fixture()
      assert Tracker.get_medication!(medication.id) == medication
    end

    test "create_medication/1 with valid data creates a medication" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Medication{} = medication} = Tracker.create_medication(valid_attrs)
      assert medication.name == "some name"
    end

    test "create_medication/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_medication(@invalid_attrs)
    end

    test "update_medication/2 with valid data updates the medication" do
      medication = medication_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Medication{} = medication} = Tracker.update_medication(medication, update_attrs)
      assert medication.name == "some updated name"
    end

    test "update_medication/2 with invalid data returns error changeset" do
      medication = medication_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_medication(medication, @invalid_attrs)
      assert medication == Tracker.get_medication!(medication.id)
    end

    test "delete_medication/1 deletes the medication" do
      medication = medication_fixture()
      assert {:ok, %Medication{}} = Tracker.delete_medication(medication)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_medication!(medication.id) end
    end

    test "change_medication/1 returns a medication changeset" do
      medication = medication_fixture()
      assert %Ecto.Changeset{} = Tracker.change_medication(medication)
    end
  end
end
