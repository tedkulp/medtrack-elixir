defmodule Medtrack.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  alias Medtrack.Repo

  alias Medtrack.Tracker.Dose
  alias Medtrack.Tracker.Medication
  alias Medtrack.Tracker.Refill

  @pub_sub_topic "medications"

  def subscribe() do
    Phoenix.PubSub.subscribe(Medtrack.PubSub, @pub_sub_topic)
  end

  def broadcast({:ok, dose}, tag) do
    Phoenix.PubSub.broadcast(Medtrack.PubSub, @pub_sub_topic, {tag, dose})

    {:ok, dose}
  end

  def broadcast({:error, _changeset} = error, _tag), do: error

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

  def get_medication_by_name!(name, user) do
    Repo.get_by(Medication, name: name, user_id: user.id)
  end

  def get_remaining_count!(medication_id) do
    refill = get_last_refill(medication_id)

    if !refill do
      0
    else
      taken_count =
        from(Dose)
        |> where([d], d.taken_at >= ^refill.filled_at and d.medication_id == ^medication_id)
        |> Repo.aggregate(:sum, :quantity) || 0

      refill.quantity - taken_count
    end
  end

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

  @doc """
  Returns the list of doses.

  ## Examples

      iex> list_doses()
      [%Dose{}, ...]

  """
  def list_doses(medication_id, options) when is_map(options) do
    from(Dose)
    |> where([d], d.medication_id == ^medication_id)
    |> sort(options)
    |> paginate(options)
    |> preload(:medication)
    |> Repo.all()
  end

  def list_doses(medication_id) do
    list_doses(medication_id, %{sort_by: :taken_at, sort_order: :asc})
  end

  def get_dose_counts(medication_id) do
    from(Dose)
    |> where([d], d.medication_id == ^medication_id)
    |> count_by_month(:taken_at)
    |> Repo.all()
    |> Enum.map(fn [month, year, count] ->
      {format_month_year(month, year), count || 0}
    end)
  end

  defp sort(query, %{sort_by: sort_by, sort_order: sort_order}) do
    order_by(query, {^sort_order, ^sort_by})
  end

  defp sort(query, _options), do: query

  defp paginate(query, %{page: page, per_page: per_page}) do
    offset = max((page - 1) * per_page, 0)

    query
    |> limit(^per_page)
    |> offset(^offset)
  end

  defp paginate(query, _options), do: query

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

  def get_last_dose(medication_id) do
    get_last_dose_query(medication_id)
    |> Repo.one()
  end

  def get_last_dose!(medication_id) do
    get_last_dose_query(medication_id)
    |> Repo.one!()
  end

  defp get_last_dose_query(medication_id) do
    from(d in Dose,
      where: d.medication_id == ^medication_id,
      order_by: [desc: d.taken_at],
      limit: 1
    )
  end

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
    |> broadcast(:dose_created)
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

  @doc """
  Returns the list of refills.

  ## Examples

      iex> list_refills()
      [%Refill{}, ...]

  """
  def list_refills(medication_id) do
    from(Refill)
    |> where([d], d.medication_id == ^medication_id)
    |> preload(:medication)
    |> Repo.all()
  end

  @doc """
  Gets a single refill.

  Raises `Ecto.NoResultsError` if the Refill does not exist.

  ## Examples

      iex> get_refill!(123)
      %Refill{}

      iex> get_refill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_refill!(id), do: Repo.get!(Refill, id)

  def get_last_refill(medication_id) do
    get_last_refill_query(medication_id)
    |> Repo.one()
  end

  def get_last_refill!(medication_id) do
    get_last_refill_query(medication_id)
    |> Repo.one!()
  end

  defp get_last_refill_query(medication_id) do
    from(r in Refill,
      where: r.medication_id == ^medication_id,
      order_by: [desc: r.filled_at],
      limit: 1
    )
  end

  @doc """
  Creates a refill.

  ## Examples

      iex> create_refill(%{field: value})
      {:ok, %Refill{}}

      iex> create_refill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_refill(attrs \\ %{}, medication_id) do
    attrs = Map.put(attrs, "medication_id", medication_id)

    %Refill{}
    |> Refill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a refill.

  ## Examples

      iex> update_refill(refill, %{field: new_value})
      {:ok, %Refill{}}

      iex> update_refill(refill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_refill(%Refill{} = refill, attrs, medication_id) do
    existing_refill = get_refill!(refill.id)

    if existing_refill.id == refill.id do
      refill = Map.put(refill, "medication_id", medication_id)

      refill
      |> Refill.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a refill.

  ## Examples

      iex> delete_refill(refill)
      {:ok, %Refill{}}

      iex> delete_refill(refill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_refill(%Refill{} = refill, medication_id) do
    existing_refill = get_refill!(refill.id)

    if to_string(existing_refill.medication_id) == to_string(medication_id) do
      Repo.delete(refill)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking refill changes.

  ## Examples

      iex> change_refill(refill)
      %Ecto.Changeset{data: %Refill{}}

  """
  def change_refill(%Refill{} = refill, attrs \\ %{}) do
    Refill.changeset(refill, attrs)
  end

  defp count_by_month(query, date_field) do
    query
    |> group_by(
      [r],
      fragment(
        "date_part('month', ?), date_part('year', ?)",
        type(field(r, ^date_field), :date),
        type(field(r, ^date_field), :date)
      )
    )
    |> order_by([r],
      asc:
        fragment(
          "date_part('year', ?)",
          type(field(r, ^date_field), :date)
        ),
      asc:
        fragment(
          "date_part('month', ?)",
          type(field(r, ^date_field), :date)
        )
    )
    |> select([r], [
      fragment(
        "date_part('month', ?)",
        type(field(r, ^date_field), :date)
      ),
      fragment(
        "date_part('year', ?)",
        type(field(r, ^date_field), :date)
      ),
      sum(type(r.quantity, :integer))
    ])
  end

  defp format_month_year(month, year) do
    month = month |> round |> Integer.to_string() |> String.pad_leading(2, "0")
    year = year |> round |> Integer.to_string() |> String.pad_leading(4, "0")
    "#{year}-#{month}"
  end
end
