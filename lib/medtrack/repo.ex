defmodule Medtrack.Repo do
  use Ecto.Repo,
    otp_app: :medtrack,
    adapter: Ecto.Adapters.Postgres
end
