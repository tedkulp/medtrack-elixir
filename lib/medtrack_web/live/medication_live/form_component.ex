defmodule MedtrackWeb.MedicationLive.FormComponent do
  use MedtrackWeb, :live_component

  alias Medtrack.Tracker

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage medication records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="medication-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Medication</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{medication: medication} = assigns, socket) do
    changeset = Tracker.change_medication(medication)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"medication" => medication_params}, socket) do
    changeset =
      socket.assigns.medication
      |> Tracker.change_medication(medication_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"medication" => medication_params}, socket) do
    save_medication(socket, socket.assigns.action, medication_params)
  end

  defp save_medication(socket, :edit, medication_params) do
    case Tracker.update_medication(
           socket.assigns.medication,
           medication_params,
           socket.assigns.current_user
         ) do
      {:ok, medication} ->
        notify_parent({:saved, medication})

        {:noreply,
         socket
         |> put_flash(:info, "Medication updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_medication(socket, :new, medication_params) do
    case Tracker.create_medication(medication_params, socket.assigns.current_user) do
      {:ok, medication} ->
        notify_parent({:saved, medication})

        {:noreply,
         socket
         |> put_flash(:info, "Medication created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
