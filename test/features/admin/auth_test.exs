defmodule AisfWeb.Admin.AuthTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

  setup do
    {:ok, champion1} =
      Factory.create_champion_with(%{sport: "Saut", years_in_french_team: [1973, 1999, 2018]})

    {:ok, champion1: champion1}
  end

  test "visiting a champion edition page gets me redirected if I'm not logged in", %{
    session: session
  } do
    session
    |> visit("/elixir/champions/edit/1")
    |> refute_has(Query.text("ÉDITER LA FICHE CHAMPION"))

    refute(String.ends_with?(current_url(session), "/champions/edit/1"))
  end

  test "visiting a champion edition page allows me in if I have the right cookie", %{
    session: session
  } do
    session
    |> visit("/elixir/")
    |> set_cookie("isAdmin", "1")
    |> visit("/elixir/champions/edit/1")
    |> assert_has(Query.text("ÉDITER LA FICHE CHAMPION", count: 1))

    assert(String.ends_with?(current_url(session), "/champions/edit/1"))
  end
end
