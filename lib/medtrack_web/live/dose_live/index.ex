defmodule MedtrackWeb.DoseLive.Index do
  require Logger

  use MedtrackWeb, :live_view

  import Medtrack.DateTimeUtil, only: [format_time: 2]

  alias Medtrack.Tracker
  alias Medtrack.Tracker.Dose

  @default_locale "en"
  @default_timezone "UTC"
  @default_timezone_offset 0

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     stream(
       assign_locale(socket),
       :doses,
       Tracker.list_doses(params["medication_id"], %{sort_by: :taken_at, sort_order: :desc})
     )}
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

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id, "medication_id" => medication_id}) do
    socket
    |> assign(:page_title, "Edit Dose")
    |> assign(:medication_id, medication_id)
    |> assign(:dose, Tracker.get_dose_with_date_offset!(id, socket.assigns.timezone))
  end

  defp apply_action(socket, :new, params) do
    {:ok, now} = DateTime.now(socket.assigns.timezone, Timex.Timezone.Database)

    socket
    |> assign(:page_title, "New Dose")
    |> assign(:medication_id, params["medication_id"])
    |> assign(:dose, %Dose{
      taken_at: now,
      quantity: 1
    })
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Doses")
    |> assign(:medication_id, params["medication_id"])
    |> assign(:dose, nil)
  end

  @impl true
  def handle_info({MedtrackWeb.DoseLive.FormComponent, {:saved, dose}}, socket) do
    {:noreply, stream_insert(socket, :doses, dose)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dose = Tracker.get_dose!(id)
    {:ok, _} = Tracker.delete_dose(dose, socket.assigns.medication_id)

    {:noreply, stream_delete(socket, :doses, dose)}
  end
end
