defmodule Medtrack.TrackerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Medtrack.Tracker` context.
  """

  @doc """
  Generate a medication.
  """
  def medication_fixture(attrs \\ %{}) do
    {:ok, medication} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Medtrack.Tracker.create_medication()

    medication
  end

  @doc """
  Generate a dose.
  """
  def dose_fixture(attrs \\ %{}) do
    {:ok, dose} =
      attrs
      |> Enum.into(%{
        quantity: 42,
        taken_at: ~N[2023-04-22 13:12:00]
      })
      |> Medtrack.Tracker.create_dose()

    dose
  end
end
