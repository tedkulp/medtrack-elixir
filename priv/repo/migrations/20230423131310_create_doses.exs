defmodule Medtrack.Repo.Migrations.CreateDoses do
  use Ecto.Migration

  def change do
    create table(:doses) do
      add :taken_at, :naive_datetime
      add :quantity, :integer
      add :medication_id, references(:medications, on_delete: :nothing)

      timestamps()
    end

    create index(:doses, [:medication_id])
  end
end
