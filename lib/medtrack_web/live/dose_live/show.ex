defmodule MedtrackWeb.DoseLive.Show do
  use MedtrackWeb, :live_view

  alias Medtrack.Tracker

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "medication_id" => medication_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:medication, Tracker.get_medication!(medication_id))
     |> assign(:dose, Tracker.get_dose!(id))}
  end

  defp page_title(:show), do: "Show Dose"
  defp page_title(:edit), do: "Edit Dose"
end
