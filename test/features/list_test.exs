defmodule AisfWeb.UserListTest do
  use AisfWeb.FeatureCase, async: true

  import Wallaby.Query, only: [css: 2]

  test "users have names", %{session: session} do
    session
    |> visit("/champions")
    |> assert_text("Rowena")
  end
end
