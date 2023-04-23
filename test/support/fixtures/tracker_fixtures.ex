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
end
