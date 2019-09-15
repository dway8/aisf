defmodule AisfWeb.Admin.AuthTest do
  use AisfWeb.FeatureCase, async: true

  test "visiting the admin page gets me redirected if I'm not logged in", %{session: session} do
    session
    |> visit("/admin")
    |> refute_has(Query.link("Ajouter champion"))

    refute(String.ends_with?(current_url(session), "/admin"))
  end

  test "visiting the admin page allows me in if I have the right cookie", %{session: session} do
    session
    |> visit("/")
    |> set_cookie("isAdmin", "1")
    |> visit("/admin")
    |> assert_has(Query.link("Ajouter champion", count: 1))

    assert(String.ends_with?(current_url(session), "/admin"))
  end
end
