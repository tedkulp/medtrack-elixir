defmodule MedtrackWeb.MedicationLive.Show do
  use MedtrackWeb, :live_view

  import Medtrack.DateTimeUtil, only: [format_time: 2]

  alias Medtrack.Tracker

  @default_locale "en"
  @default_timezone "UTC"
  @default_timezone_offset 0

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_locale(socket)}
  end

  defp assign_locale(socket) do
    locale = get_connect_params(socket)["locale"] || @default_locale
    timezone = get_connect_params(socket)["timezone"] || @default_timezone
    timezone_offset = get_connect_params(socket)["timezone_offset"] || @default_timezone_offset
    assign(socket, locale: locale, timezone: timezone, timezone_offset: timezone_offset)
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:medication, Tracker.get_medication!(id))
     |> assign(:last_dose, Tracker.get_last_dose(id))
     |> assign(:last_refill, Tracker.get_last_refill(id))
     |> assign(:remaining_count, Tracker.get_remaining_count!(id))}
  end

  defp page_title(:show), do: "Show Medication"
  defp page_title(:edit), do: "Edit Medication"
end
