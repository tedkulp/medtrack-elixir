defmodule MedtrackWeb.API.TrackerController do
  use MedtrackWeb, :controller

  def stats(conn, _params) do
    render(conn, :stats, %{})
  end
end
