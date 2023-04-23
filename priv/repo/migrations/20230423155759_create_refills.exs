defmodule Medtrack.Repo.Migrations.CreateRefills do
  use Ecto.Migration

  def change do
    create table(:refills) do
      add :filled_at, :naive_datetime
      add :quantity, :integer
      add :medication_id, references(:medications, on_delete: :nothing)

      timestamps()
    end

    create index(:refills, [:medication_id])
  end
end
