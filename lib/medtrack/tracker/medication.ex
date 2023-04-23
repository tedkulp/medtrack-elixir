defmodule Medtrack.Tracker.Medication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "medications" do
    field :name, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(medication, attrs) do
    medication
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
