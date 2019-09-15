defmodule AisfWeb.MedalsTest do
  use AisfWeb.FeatureCase, async: true

  alias Aisf.Champions

  setup do
    medals1 = [
      %{
        competition: "OlympicGames",
        medal_type: 2,
        specialty: "Poursuite",
        year: 1992
      },
      %{
        competition: "WorldChampionships",
        medal_type: 1,
        specialty: "General",
        year: 1981
      }
    ]

    medals2 = [
      %{
        competition: "WorldCup",
        medal_type: 3,
        specialty: "ParEquipe",
        year: 2019
      }
    ]

    {:ok, champion1} = create_champion_with_sport_and_medals("Ski de fond", medals1)
    {:ok, champion2} = create_champion_with_sport_and_medals("Combiné nordique", medals2)

    {:ok, champion1: champion1, champion2: champion2}
  end

  test "not viewing anything if no sport selected", %{session: session} do
    session
    |> visit("/medals")
    |> assert_has(Query.css(".champion-item", count: 0))
  end

  test "filtering medals by sport", %{
    session: session,
    champion1: champion1,
    champion2: champion2
  } do
    session
    |> visit("/medals")
    |> click(Query.text("Tous les sports"))
    |> click(Query.option("Ski de fond"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 2))
      |> assert_has(Query.text("Argent"))
      |> assert_has(Query.text("Cl. général"))
      |> assert_has(Query.text(champion1.first_name, count: 2))
    end)

    session
    |> click(Query.option("Combiné nordique"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 1))
      |> assert_has(Query.text(champion2.first_name))
      |> assert_has(Query.text("Bronze"))
    end)
  end

  test "filtering medals by sport and medals", %{session: session, champion1: champion1} do
    session
    |> visit("/medals")
    |> click(Query.option("Tous les sports"))
    |> click(Query.option("Ski de fond"))
    |> click(Query.option("Toutes les spécialités"))
    |> click(Query.option("Poursuite"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 1))
      |> assert_has(Query.text("Argent"))
      |> assert_has(Query.text("1992"))
      |> assert_has(Query.text(champion1.first_name, count: 1))
    end)

    session
    |> click(Query.option("Toutes les spécialités"))
    |> assert_has(Query.css(".champion-item", count: 2))
  end

  test "filtering medals by sport and year", %{session: session} do
    session
    |> visit("/medals")
    |> click(Query.option("Tous les sports"))
    |> click(Query.option("Ski de fond"))
    |> click(Query.option("Toutes les années"))
    |> click(Query.option("1992"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 1))
      |> assert_has(Query.text("Argent"))
      |> assert_has(Query.text("1992"))
    end)

    session
    |> click(Query.option("1981"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 1))
      |> assert_has(Query.text("Or"))
      |> assert_has(Query.text("1981"))
    end)

    session
    |> click(Query.option("Toutes les années"))
    |> assert_has(Query.css(".champion-item", count: 2))
  end

  test "selecting a champion in the list", %{
    session: session,
    champion1: champion1
  } do
    session
    |> visit("/medals")
    |> click(Query.option("Ski de fond"))
    |> click(Query.text(champion1.first_name, count: 2, at: 1))
    |> assert_has(Query.text("EXPÉRIENCES PROFESSIONNELLES"))

    assert(
      String.ends_with?(
        current_url(session),
        "/champions/" <> to_string(champion1.id)
      )
    )
  end

  defp create_champion_with_sport_and_medals(sport, medals) do
    champion = %{
      last_name: Faker.Name.last_name(),
      first_name: Faker.Name.first_name(),
      email: Faker.Internet.free_email(),
      password: Faker.UUID.v4(),
      sport: sport,
      years_in_french_team: [],
      pro_experiences: [],
      medals: medals
    }

    Champions.create_champion(champion)
  end
end
