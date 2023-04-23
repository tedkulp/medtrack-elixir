defmodule Medtrack.Tracker.Refill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "refills" do
    field :filled_at, :naive_datetime
    field :quantity, :integer

    belongs_to :medication, Medtrack.Tracker.Medication

    timestamps()
  end

  @doc false
  def changeset(refill, attrs) do
    refill
    |> cast(attrs, [:filled_at, :quantity, :medication_id])
    |> validate_required([:filled_at, :quantity, :medication_id])
  end
end
