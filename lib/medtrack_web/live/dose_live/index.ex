defmodule MedtrackWeb.DoseLive.Index do
  use MedtrackWeb, :live_view

  alias Medtrack.Tracker
  alias Medtrack.Tracker.Dose

  @impl true
  def mount(params, _session, socket) do
    {:ok, stream(socket, :doses, Tracker.list_doses(params["medication_id"]))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id, "medication_id" => medication_id}) do
    socket
    |> assign(:page_title, "Edit Dose")
    |> assign(:medication_id, medication_id)
    |> assign(:dose, Tracker.get_dose!(id))
  end

  defp apply_action(socket, :new, params) do
    socket
    |> assign(:page_title, "New Dose")
    |> assign(:medication_id, params["medication_id"])
    |> assign(:dose, %Dose{taken_at: DateTime.utc_now(), quantity: 1})
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
