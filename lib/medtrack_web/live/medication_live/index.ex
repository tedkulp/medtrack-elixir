defmodule MedtrackWeb.MedicationLive.Index do
  use MedtrackWeb, :live_view

  alias Medtrack.Tracker
  alias Medtrack.Tracker.Medication

  import Medtrack.DateTimeUtil, only: [format_time: 2]

  @default_locale "en"
  @default_timezone "UTC"
  @default_timezone_offset 0

  @impl true
  def mount(_params, _session, socket) do
    socket = assign_locale(socket)
    {:ok, stream(socket, :medications, Tracker.list_medications(socket.assigns.current_user))}
  end

  defp assign_locale(socket) do
    locale = get_connect_params(socket)["locale"] || @default_locale
    timezone = get_connect_params(socket)["timezone"] || @default_timezone
    timezone_offset = get_connect_params(socket)["timezone_offset"] || @default_timezone_offset
    assign(socket, locale: locale, timezone: timezone, timezone_offset: timezone_offset)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Medication")
    |> assign(:medication, Tracker.get_medication!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Medication")
    |> assign(:medication, %Medication{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Medications")
    |> assign(:medication, nil)
  end

  @impl true
  def handle_info({MedtrackWeb.MedicationLive.FormComponent, {:saved, medication}}, socket) do
    {:noreply, stream_insert(socket, :medications, medication)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    medication = Tracker.get_medication!(id)
    {:ok, _} = Tracker.delete_medication(medication, socket.assigns.current_user)

    {:noreply, stream_delete(socket, :medications, medication)}
  end

  def handle_event("fill-medication-chart", _, socket) do
    data =
      Tracker.list_medications(socket.assigns.current_user)
      |> Enum.map(fn medication ->
        counts =
          medication.id
          |> Tracker.get_dose_counts()
          |> Enum.map(fn {date, count} -> %{date: date, count: count} end)

        %{name: medication.name, counts: counts}
      end)

    {:reply, %{data: data}, socket}
  end

  defp get_last_dose(medication) do
    Tracker.get_last_dose(medication.id)
    |> case do
      %{taken_at: taken_at} -> taken_at
      _ -> nil
    end
  end

  defp get_last_refill(medication) do
    Tracker.get_last_refill(medication.id)
    |> case do
      %{filled_at: filled_at} -> filled_at
      _ -> nil
    end
  end

  defp get_remaining_count(medication) do
    Tracker.get_remaining_count!(medication.id)
  end
end
