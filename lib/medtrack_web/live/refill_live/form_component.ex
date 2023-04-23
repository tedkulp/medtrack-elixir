defmodule MedtrackWeb.RefillLive.FormComponent do
  use MedtrackWeb, :live_component

  alias Medtrack.Tracker

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage refill records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="refill-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:filled_at]} type="datetime-local" label="Filled at" />
        <.input field={@form[:quantity]} type="number" label="Quantity" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Refill</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{refill: refill} = assigns, socket) do
    changeset = Tracker.change_refill(refill)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"refill" => refill_params}, socket) do
    changeset =
      socket.assigns.refill
      |> Tracker.change_refill(refill_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"refill" => refill_params}, socket) do
    save_refill(socket, socket.assigns.action, refill_params)
  end

  defp save_refill(socket, :edit, refill_params) do
    case Tracker.update_refill(socket.assigns.refill, refill_params, socket.assigns.medication_id) do
      {:ok, refill} ->
        notify_parent({:saved, refill})

        {:noreply,
         socket
         |> put_flash(:info, "Refill updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_refill(socket, :new, refill_params) do
    case Tracker.create_refill(refill_params, socket.assigns.medication_id) do
      {:ok, refill} ->
        notify_parent({:saved, refill})

        {:noreply,
         socket
         |> put_flash(:info, "Refill created successfully")
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
