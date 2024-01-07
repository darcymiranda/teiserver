defmodule TeiserverWeb.Live.Account.Profile.OverviewTest do
  use TeiserverWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  alias Central.Helpers.GeneralTestLib
  alias Teiserver.{Battle, TeiserverTestLib, Client}

  setup do
    {:ok, data} =
      TeiserverTestLib.player_permissions()
      |> GeneralTestLib.conn_setup()
      |> TeiserverTestLib.conn_setup()

    profile_user = GeneralTestLib.make_user()
    login_user(profile_user)

    %{conn: data[:conn], user: data[:user], profile_user: profile_user}
  end

  describe "join lobby" do
    test "clicking join joins the client to the user's lobby", %{conn: conn, user: user, profile_user: profile_user} do
      login_user(user)

      lobby_id = TeiserverTestLib.make_lobby()

      Battle.force_add_user_to_lobby(profile_user.id, lobby_id)

      {:ok, view, _html} = live(conn, "/profile/#{profile_user.id}")

      view
      |> element("span[phx-click=join]")
      |> render_click()

      assert user.id in Battle.get_lobby_member_list(lobby_id)
    end

    test "renders error flash when client is not connected", %{conn: conn, profile_user: profile_user} do
      # Skip client login

      lobby_id = TeiserverTestLib.make_lobby()

      Battle.force_add_user_to_lobby(profile_user.id, lobby_id)

      {:ok, view, _html} = live(conn, "/profile/#{profile_user.id}")

      view
      |> element("span[phx-click=join]")
      |> render_click()

      assert render(view) =~ "Client is not connected"
    end
  end

  defp login_user(user) do
    user
    |> Map.merge(%{rank: 1, print_client_messages: false, print_server_messages: false})
    |> Client.login(:spring, "127.0.0.1")
  end
end
