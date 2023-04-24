defmodule MedtrackWeb.MedicationLive.Index do
  use MedtrackWeb, :live_view

  alias Medtrack.Tracker
  alias Medtrack.Tracker.Medication

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :medications, Tracker.list_medications(socket.assigns.current_user))}
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
end
