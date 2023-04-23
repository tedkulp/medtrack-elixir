defmodule MedtrackWeb.MedicationLiveTest do
  use MedtrackWeb.ConnCase

  import Phoenix.LiveViewTest
  import Medtrack.TrackerFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_medication(_) do
    medication = medication_fixture()
    %{medication: medication}
  end

  describe "Index" do
    setup [:create_medication]

    test "lists all medications", %{conn: conn, medication: medication} do
      {:ok, _index_live, html} = live(conn, ~p"/medications")

      assert html =~ "Listing Medications"
      assert html =~ medication.name
    end

    test "saves new medication", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/medications")

      assert index_live |> element("a", "New Medication") |> render_click() =~
               "New Medication"

      assert_patch(index_live, ~p"/medications/new")

      assert index_live
             |> form("#medication-form", medication: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#medication-form", medication: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/medications")

      html = render(index_live)
      assert html =~ "Medication created successfully"
      assert html =~ "some name"
    end

    test "updates medication in listing", %{conn: conn, medication: medication} do
      {:ok, index_live, _html} = live(conn, ~p"/medications")

      assert index_live |> element("#medications-#{medication.id} a", "Edit") |> render_click() =~
               "Edit Medication"

      assert_patch(index_live, ~p"/medications/#{medication}/edit")

      assert index_live
             |> form("#medication-form", medication: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#medication-form", medication: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/medications")

      html = render(index_live)
      assert html =~ "Medication updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes medication in listing", %{conn: conn, medication: medication} do
      {:ok, index_live, _html} = live(conn, ~p"/medications")

      assert index_live |> element("#medications-#{medication.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#medications-#{medication.id}")
    end
  end

  describe "Show" do
    setup [:create_medication]

    test "displays medication", %{conn: conn, medication: medication} do
      {:ok, _show_live, html} = live(conn, ~p"/medications/#{medication}")

      assert html =~ "Show Medication"
      assert html =~ medication.name
    end

    test "updates medication within modal", %{conn: conn, medication: medication} do
      {:ok, show_live, _html} = live(conn, ~p"/medications/#{medication}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Medication"

      assert_patch(show_live, ~p"/medications/#{medication}/show/edit")

      assert show_live
             |> form("#medication-form", medication: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#medication-form", medication: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/medications/#{medication}")

      html = render(show_live)
      assert html =~ "Medication updated successfully"
      assert html =~ "some updated name"
    end
  end
end
