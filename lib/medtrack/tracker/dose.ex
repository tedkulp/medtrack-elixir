defmodule Medtrack.Tracker.Dose do
  use Ecto.Schema
  import Ecto.Changeset

  schema "doses" do
    field :quantity, :integer
    field :taken_at, :naive_datetime

    belongs_to :medication, Medtrack.Tracker.Medication

    timestamps()
  end

  @doc false
  def changeset(dose, attrs) do
    dose
    |> cast(attrs, [:taken_at, :quantity, :medication_id])
    |> validate_required([:taken_at, :quantity, :medication_id])
  end
end
