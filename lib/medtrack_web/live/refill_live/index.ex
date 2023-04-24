defmodule MedtrackWeb.RefillLive.Index do
  use MedtrackWeb, :live_view

  alias Medtrack.Tracker
  alias Medtrack.Tracker.Refill

  @impl true
  def mount(params, _session, socket) do
    {:ok, stream(socket, :refills, Tracker.list_refills(params["medication_id"]))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id, "medication_id" => medication_id}) do
    socket
    |> assign(:page_title, "Edit Refill")
    |> assign(:medication_id, medication_id)
    |> assign(:refill, Tracker.get_refill!(id))
  end

  defp apply_action(socket, :new, params) do
    socket
    |> assign(:page_title, "New Refill")
    |> assign(:medication_id, params["medication_id"])
    |> assign(:refill, %Refill{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Refills")
    |> assign(:medication_id, params["medication_id"])
    |> assign(:refill, nil)
  end

  @impl true
  def handle_info({MedtrackWeb.RefillLive.FormComponent, {:saved, refill}}, socket) do
    {:noreply, stream_insert(socket, :refills, refill)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    refill = Tracker.get_refill!(id)
    {:ok, _} = Tracker.delete_refill(refill, socket.assigns.medication_id)

    {:noreply, stream_delete(socket, :refills, refill)}
  end
end
