defmodule Medtrack.Tracker.Medication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "medications" do
    field :name, :string
    field :user_id, :id

    has_many :doses, Medtrack.Tracker.Dose

    timestamps()
  end

  @doc false
  def changeset(medication, attrs) do
    medication
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
