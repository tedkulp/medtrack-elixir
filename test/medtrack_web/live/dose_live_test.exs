defmodule MedtrackWeb.DoseLiveTest do
  use MedtrackWeb.ConnCase

  import Phoenix.LiveViewTest
  import Medtrack.TrackerFixtures

  @create_attrs %{quantity: 42, taken_at: "2023-04-22T13:12:00"}
  @update_attrs %{quantity: 43, taken_at: "2023-04-23T13:12:00"}
  @invalid_attrs %{quantity: nil, taken_at: nil}

  defp create_dose(_) do
    dose = dose_fixture()
    %{dose: dose}
  end

  describe "Index" do
    setup [:create_dose]

    test "lists all doses", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/doses")

      assert html =~ "Listing Doses"
    end

    test "saves new dose", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/doses")

      assert index_live |> element("a", "New Dose") |> render_click() =~
               "New Dose"

      assert_patch(index_live, ~p"/doses/new")

      assert index_live
             |> form("#dose-form", dose: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#dose-form", dose: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/doses")

      html = render(index_live)
      assert html =~ "Dose created successfully"
    end

    test "updates dose in listing", %{conn: conn, dose: dose} do
      {:ok, index_live, _html} = live(conn, ~p"/doses")

      assert index_live |> element("#doses-#{dose.id} a", "Edit") |> render_click() =~
               "Edit Dose"

      assert_patch(index_live, ~p"/doses/#{dose}/edit")

      assert index_live
             |> form("#dose-form", dose: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#dose-form", dose: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/doses")

      html = render(index_live)
      assert html =~ "Dose updated successfully"
    end

    test "deletes dose in listing", %{conn: conn, dose: dose} do
      {:ok, index_live, _html} = live(conn, ~p"/doses")

      assert index_live |> element("#doses-#{dose.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#doses-#{dose.id}")
    end
  end

  describe "Show" do
    setup [:create_dose]

    test "displays dose", %{conn: conn, dose: dose} do
      {:ok, _show_live, html} = live(conn, ~p"/doses/#{dose}")

      assert html =~ "Show Dose"
    end

    test "updates dose within modal", %{conn: conn, dose: dose} do
      {:ok, show_live, _html} = live(conn, ~p"/doses/#{dose}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Dose"

      assert_patch(show_live, ~p"/doses/#{dose}/show/edit")

      assert show_live
             |> form("#dose-form", dose: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#dose-form", dose: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/doses/#{dose}")

      html = render(show_live)
      assert html =~ "Dose updated successfully"
    end
  end
end
