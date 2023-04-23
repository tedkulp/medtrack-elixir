defmodule MedtrackWeb.RefillLiveTest do
  use MedtrackWeb.ConnCase

  import Phoenix.LiveViewTest
  import Medtrack.TrackerFixtures

  @create_attrs %{filled_at: "2023-04-22T15:57:00", quantity: 42}
  @update_attrs %{filled_at: "2023-04-23T15:57:00", quantity: 43}
  @invalid_attrs %{filled_at: nil, quantity: nil}

  defp create_refill(_) do
    refill = refill_fixture()
    %{refill: refill}
  end

  describe "Index" do
    setup [:create_refill]

    test "lists all refills", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/refills")

      assert html =~ "Listing Refills"
    end

    test "saves new refill", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/refills")

      assert index_live |> element("a", "New Refill") |> render_click() =~
               "New Refill"

      assert_patch(index_live, ~p"/refills/new")

      assert index_live
             |> form("#refill-form", refill: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#refill-form", refill: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/refills")

      html = render(index_live)
      assert html =~ "Refill created successfully"
    end

    test "updates refill in listing", %{conn: conn, refill: refill} do
      {:ok, index_live, _html} = live(conn, ~p"/refills")

      assert index_live |> element("#refills-#{refill.id} a", "Edit") |> render_click() =~
               "Edit Refill"

      assert_patch(index_live, ~p"/refills/#{refill}/edit")

      assert index_live
             |> form("#refill-form", refill: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#refill-form", refill: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/refills")

      html = render(index_live)
      assert html =~ "Refill updated successfully"
    end

    test "deletes refill in listing", %{conn: conn, refill: refill} do
      {:ok, index_live, _html} = live(conn, ~p"/refills")

      assert index_live |> element("#refills-#{refill.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#refills-#{refill.id}")
    end
  end

  describe "Show" do
    setup [:create_refill]

    test "displays refill", %{conn: conn, refill: refill} do
      {:ok, _show_live, html} = live(conn, ~p"/refills/#{refill}")

      assert html =~ "Show Refill"
    end

    test "updates refill within modal", %{conn: conn, refill: refill} do
      {:ok, show_live, _html} = live(conn, ~p"/refills/#{refill}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Refill"

      assert_patch(show_live, ~p"/refills/#{refill}/show/edit")

      assert show_live
             |> form("#refill-form", refill: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#refill-form", refill: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/refills/#{refill}")

      html = render(show_live)
      assert html =~ "Refill updated successfully"
    end
  end
end
