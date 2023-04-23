defmodule Medtrack.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  alias Medtrack.Repo

  alias Medtrack.Tracker.Medication

  @doc """
  Returns the list of medications.

  ## Examples

      iex> list_medications()
      [%Medication{}, ...]

  """
  def list_medications do
    Repo.all(Medication)
  end

  def list_medications(user) do
    from(Medication)
    |> where([m], m.user_id == ^user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single medication.

  Raises `Ecto.NoResultsError` if the Medication does not exist.

  ## Examples

      iex> get_medication!(123)
      %Medication{}

      iex> get_medication!(456)
      ** (Ecto.NoResultsError)

  """
  def get_medication!(id), do: Repo.get!(Medication, id)

  @doc """
  Creates a medication.

  ## Examples

      iex> create_medication(%{field: value})
      {:ok, %Medication{}}

      iex> create_medication(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_medication(attrs \\ %{}, user) do
    attrs = Map.put(attrs, "user_id", user.id)

    %Medication{}
    |> Medication.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a medication.

  ## Examples

      iex> update_medication(medication, %{field: new_value})
      {:ok, %Medication{}}

      iex> update_medication(medication, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_medication(%Medication{} = medication, attrs, user) do
    existing_med = get_medication!(medication.id)

    if existing_med.user_id == user.id do
      medication = Map.put(medication, "user_id", user.id)

      medication
      |> Medication.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a medication.

  ## Examples

      iex> delete_medication(medication)
      {:ok, %Medication{}}

      iex> delete_medication(medication)
      {:error, %Ecto.Changeset{}}

  """
  def delete_medication(%Medication{} = medication, user) do
    existing_med = get_medication!(medication.id)

    if existing_med.user_id == user.id do
      Repo.delete(medication)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking medication changes.

  ## Examples

      iex> change_medication(medication)
      %Ecto.Changeset{data: %Medication{}}

  """
  def change_medication(%Medication{} = medication, attrs \\ %{}) do
    Medication.changeset(medication, attrs)
  end

  alias Medtrack.Tracker.Dose

  @doc """
  Returns the list of doses.

  ## Examples

      iex> list_doses()
      [%Dose{}, ...]

  """
  def list_doses(medication_id) do
    from(Dose)
    |> where([d], d.medication_id == ^medication_id)
    |> preload(:medication)
    |> Repo.all()
  end

  @doc """
  Gets a single dose.

  Raises `Ecto.NoResultsError` if the Dose does not exist.

  ## Examples

      iex> get_dose!(123)
      %Dose{}

      iex> get_dose!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dose!(id), do: Repo.get!(Dose, id)

  @doc """
  Creates a dose.

  ## Examples

      iex> create_dose(%{field: value})
      {:ok, %Dose{}}

      iex> create_dose(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dose(attrs \\ %{}, medication_id) do
    attrs = Map.put(attrs, "medication_id", medication_id)

    %Dose{}
    |> Dose.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dose.

  ## Examples

      iex> update_dose(dose, %{field: new_value}, 1)
      {:ok, %Dose{}}

      iex> update_dose(dose, %{field: bad_value}, 1)
      {:error, %Ecto.Changeset{}}

  """
  def update_dose(%Dose{} = dose, attrs, medication_id) do
    existing_dose = get_dose!(dose.id)

    if existing_dose.id == dose.id do
      dose = Map.put(dose, "medication_id", medication_id)

      dose
      |> Dose.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a dose.

  ## Examples

      iex> delete_dose(dose)
      {:ok, %Dose{}}

      iex> delete_dose(dose)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dose(%Dose{} = dose, medication_id) do
    existing_dose = get_dose!(dose.id)

    if to_string(existing_dose.medication_id) == to_string(medication_id) do
      Repo.delete(dose)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dose changes.

  ## Examples

      iex> change_dose(dose)
      %Ecto.Changeset{data: %Dose{}}

  """
  def change_dose(%Dose{} = dose, attrs \\ %{}) do
    Dose.changeset(dose, attrs)
  end
end
