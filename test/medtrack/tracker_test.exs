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

  describe "doses" do
    alias Medtrack.Tracker.Dose

    import Medtrack.TrackerFixtures

    @invalid_attrs %{quantity: nil, taken_at: nil}

    test "list_doses/0 returns all doses" do
      dose = dose_fixture()
      assert Tracker.list_doses() == [dose]
    end

    test "get_dose!/1 returns the dose with given id" do
      dose = dose_fixture()
      assert Tracker.get_dose!(dose.id) == dose
    end

    test "create_dose/1 with valid data creates a dose" do
      valid_attrs = %{quantity: 42, taken_at: ~N[2023-04-22 13:12:00]}

      assert {:ok, %Dose{} = dose} = Tracker.create_dose(valid_attrs)
      assert dose.quantity == 42
      assert dose.taken_at == ~N[2023-04-22 13:12:00]
    end

    test "create_dose/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_dose(@invalid_attrs)
    end

    test "update_dose/2 with valid data updates the dose" do
      dose = dose_fixture()
      update_attrs = %{quantity: 43, taken_at: ~N[2023-04-23 13:12:00]}

      assert {:ok, %Dose{} = dose} = Tracker.update_dose(dose, update_attrs)
      assert dose.quantity == 43
      assert dose.taken_at == ~N[2023-04-23 13:12:00]
    end

    test "update_dose/2 with invalid data returns error changeset" do
      dose = dose_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_dose(dose, @invalid_attrs)
      assert dose == Tracker.get_dose!(dose.id)
    end

    test "delete_dose/1 deletes the dose" do
      dose = dose_fixture()
      assert {:ok, %Dose{}} = Tracker.delete_dose(dose)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_dose!(dose.id) end
    end

    test "change_dose/1 returns a dose changeset" do
      dose = dose_fixture()
      assert %Ecto.Changeset{} = Tracker.change_dose(dose)
    end
  end

  describe "refills" do
    alias Medtrack.Tracker.Refill

    import Medtrack.TrackerFixtures

    @invalid_attrs %{filled_at: nil, quantity: nil}

    test "list_refills/0 returns all refills" do
      refill = refill_fixture()
      assert Tracker.list_refills() == [refill]
    end

    test "get_refill!/1 returns the refill with given id" do
      refill = refill_fixture()
      assert Tracker.get_refill!(refill.id) == refill
    end

    test "create_refill/1 with valid data creates a refill" do
      valid_attrs = %{filled_at: ~N[2023-04-22 15:57:00], quantity: 42}

      assert {:ok, %Refill{} = refill} = Tracker.create_refill(valid_attrs)
      assert refill.filled_at == ~N[2023-04-22 15:57:00]
      assert refill.quantity == 42
    end

    test "create_refill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracker.create_refill(@invalid_attrs)
    end

    test "update_refill/2 with valid data updates the refill" do
      refill = refill_fixture()
      update_attrs = %{filled_at: ~N[2023-04-23 15:57:00], quantity: 43}

      assert {:ok, %Refill{} = refill} = Tracker.update_refill(refill, update_attrs)
      assert refill.filled_at == ~N[2023-04-23 15:57:00]
      assert refill.quantity == 43
    end

    test "update_refill/2 with invalid data returns error changeset" do
      refill = refill_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracker.update_refill(refill, @invalid_attrs)
      assert refill == Tracker.get_refill!(refill.id)
    end

    test "delete_refill/1 deletes the refill" do
      refill = refill_fixture()
      assert {:ok, %Refill{}} = Tracker.delete_refill(refill)
      assert_raise Ecto.NoResultsError, fn -> Tracker.get_refill!(refill.id) end
    end

    test "change_refill/1 returns a refill changeset" do
      refill = refill_fixture()
      assert %Ecto.Changeset{} = Tracker.change_refill(refill)
    end
  end
end
