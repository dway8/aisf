defmodule AisfWeb.ChampionsTest do
  use AisfWeb.FeatureCase, async: true

  alias Aisf.Champions

  setup do
    {:ok, champion1} = create_champion_with_sport("Ski alpin")
    {:ok, champion2} = create_champion_with_sport("Biathlon")
    {:ok, champion3} = create_champion_with_sport("Ski alpin")

    {:ok, champion1: champion1, champion2: champion2, champion3: champion3}
  end

  test "viewing a list of champions", %{
    session: session,
    champion1: champion1,
    champion2: champion2,
    champion3: champion3
  } do
    session
    |> visit("/champions")
    |> assert_has(Query.css(".champion-item", count: 3))
    |> assert_has(Query.text(champion1.first_name))
    |> assert_has(Query.text(champion2.first_name))
    |> assert_has(Query.text(champion3.first_name))
  end

  test "filtering champions by sport", %{
    session: session,
    champion1: champion1,
    champion2: champion2,
    champion3: champion3
  } do
    session
    |> visit("/champions")
    |> assert_has(Query.css(".champion-item", count: 3))
    |> click(Query.text("Tous les sports"))
    |> click(Query.option("Biathlon"))
    |> assert_has(Query.css(".champion-item", count: 1))
    |> assert_has(Query.text(champion2.first_name))
    |> click(Query.option("Ski alpin"))
    |> assert_has(Query.css(".champion-item", count: 2))
    |> assert_has(Query.text(champion1.first_name))
    |> assert_has(Query.text(champion3.first_name))
  end

  test "selecting a champion in the list", %{
    session: session,
    champion1: champion1
  } do
    session
    |> visit("/champions")
    |> click(Query.text(champion1.first_name))
    |> assert_has(Query.text("EXPÉRIENCES PROFESSIONNELLES"))

    assert(
      String.ends_with?(
        current_url(session),
        "/champions/" <> to_string(champion1.id)
      )
    )
  end

  defp create_champion_with_sport(sport) do
    champion = %{
      last_name: Faker.Name.last_name(),
      first_name: Faker.Name.first_name(),
      email: Faker.Internet.free_email(),
      password: Faker.UUID.v4(),
      sport: sport,
      years_in_french_team: [],
      pro_experiences: [],
      medals: []
    }

    Champions.create_champion(champion)
  end
end
