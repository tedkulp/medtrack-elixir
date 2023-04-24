defmodule Medtrack.Repo.Migrations.AddApiKeyToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:api_key, :string)
    end

    create(index(:users, [:api_key]))
  end
end
