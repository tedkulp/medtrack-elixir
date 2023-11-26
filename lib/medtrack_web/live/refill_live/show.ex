defmodule MedtrackWeb.RefillLive.Show do
  require Logger

  use MedtrackWeb, :live_view

  alias Medtrack.Tracker
  import Medtrack.DateTimeUtil, only: [format_time: 2]

  @default_locale "en"
  @default_timezone "UTC"
  @default_timezone_offset 0

  @impl true
  def mount(_params, _session, socket) do
    socket = assign_locale(socket)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "medication_id" => medication_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:medication, Tracker.get_medication!(medication_id))
     |> assign(:refill, Tracker.get_refill!(id))}
  end

  defp assign_locale(socket) do
    locale = get_connect_params(socket)["locale"] || @default_locale
    timezone = get_connect_params(socket)["timezone"] || @default_timezone
    timezone_offset = get_connect_params(socket)["timezone_offset"] || @default_timezone_offset

    Logger.info(
      "assign_locale: #{inspect(locale)} #{inspect(timezone)} #{inspect(timezone_offset)}"
    )

    assign(socket, locale: locale, timezone: timezone, timezone_offset: timezone_offset)
  end

  defp page_title(:show), do: "Show Refill"
  defp page_title(:edit), do: "Edit Refill"
end
