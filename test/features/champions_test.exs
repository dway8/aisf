defmodule AisfWeb.ChampionsTest do
  use AisfWeb.FeatureCase, async: true

  alias Aisf.Champions

  @champion1 %{
    last_name: "Pitsu",
    first_name: "Diane",
    email: "rowena@pitsu.com",
    password: "azeaze",
    sport: "Ski alpin",
    years_in_french_team: [2001, 2003],
    pro_experiences: [],
    medals: []
  }

  setup do
    {:ok, champion1} = Champions.create_champion(@champion1)

    {:ok, champion1: champion1}
  end

  test "viewing a list of champions", %{session: session} do
    session
    |> visit("/champions")
    |> assert_text(@champion1.first_name)
  end
end
