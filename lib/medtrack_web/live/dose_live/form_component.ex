defmodule MedtrackWeb.DoseLive.FormComponent do
  use MedtrackWeb, :live_component

  alias Medtrack.Tracker

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <pre>
      <%= inspect(assigns, pretty: true) %>
      </pre>

      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage dose records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="dose-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        phx-para
      >
        <.input field={@form[:taken_at]} type="datetime-local" label="Taken at" />
        <.input field={@form[:quantity]} type="number" label="Quantity" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Dose</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{dose: dose} = assigns, socket) do
    changeset = Tracker.change_dose(dose)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"dose" => dose_params}, socket) do
    changeset =
      socket.assigns.dose
      |> Tracker.change_dose(dose_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"dose" => dose_params}, socket) do
    save_dose(socket, socket.assigns.action, dose_params)
  end

  defp save_dose(socket, :edit, dose_params) do
    case Tracker.update_dose(socket.assigns.dose, dose_params, socket.assigns.medication_id) do
      {:ok, dose} ->
        notify_parent({:saved, dose})

        {:noreply,
         socket
         |> put_flash(:info, "Dose updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_dose(socket, :new, dose_params) do
    case Tracker.create_dose(dose_params, socket.assigns.medication_id) do
      {:ok, dose} ->
        notify_parent({:saved, dose})

        {:noreply,
         socket
         |> put_flash(:info, "Dose created successfully")
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
