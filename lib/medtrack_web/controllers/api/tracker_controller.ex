defmodule MedtrackWeb.API.TrackerController do
  use MedtrackWeb, :controller

  import Medtrack.Tracker

  action_fallback(MedtrackWeb.API.MyFallbackController)

  def stats(conn, _params) do
    current_user = conn.assigns[:current_user]

    meds =
      list_medications(current_user)
      |> Enum.map(fn med ->
        %{
          id: med.id,
          name: med.name,
          last_dose: get_last_dose!(med.id).taken_at,
          last_refill: get_last_refill!(med.id).filled_at,
          remaining_count: get_remaining_count!(med.id)
        }
      end)

    json(conn, meds)
  end

  def log_dose(conn, %{"medication" => medication, "quantity" => quantity}) do
    current_user = conn.assigns[:current_user]

    medication = get_medication_by_name!(medication, current_user)

    if !medication do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{
        field: "medication",
        error: "Invalid Attribute",
        detail: "Medication not found"
      })
    else
      case create_dose(%{"quantity" => quantity, "taken_at" => DateTime.utc_now()}, medication.id) do
        {:ok, dose} ->
          json(conn, %{
            id: dose.id,
            quantity: dose.quantity,
            taken_at: dose.taken_at,
            medication_id: dose.medication_id
          })

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(render_error(changeset))
      end
    end
  end

  def add_dose(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Invalid parameters"})
  end

  defp render_error(changeset) do
    errors =
      Enum.map(changeset.errors, fn {field, detail} ->
        %{
          field: field,
          error: "Invalid Attribute",
          detail: render_detail(detail)
        }
      end)

    %{errors: errors}
  end

  defp render_detail({message, values}) do
    Enum.reduce(values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end)
  end

  defp render_detail(message) do
    message
  end
end
