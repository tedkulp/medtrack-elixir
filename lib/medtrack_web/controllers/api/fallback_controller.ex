defmodule MedtrackWeb.API.MyFallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: MedtrackWeb.ErrorJSON)
    |> json(%{error: "Not found"})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(json: MedtrackWeb.ErrorJSON)
    |> json(%{error: "Unauthorized"})
  end
end
