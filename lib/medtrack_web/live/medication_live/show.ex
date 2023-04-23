defmodule MedtrackWeb.MedicationLive.Show do
  use MedtrackWeb, :live_view

  alias Medtrack.Tracker

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:medication, Tracker.get_medication!(id))}
  end

  defp page_title(:show), do: "Show Medication"
  defp page_title(:edit), do: "Edit Medication"
end
