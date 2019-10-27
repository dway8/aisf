defmodule AisfWeb.MedalsTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

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

    {:ok, champion1} = Factory.create_champion_with(%{sport: "Ski de fond", medals: medals1})
    {:ok, champion2} = Factory.create_champion_with(%{sport: "Combiné nordique", medals: medals2})
    {:ok, champion3} = Factory.create_champion_with(%{sport: "Biathlon"})

    {:ok, champion1: champion1, champion2: champion2, champion3: champion3}
  end

  test "viewing all the champions with medals if no sport selected", %{session: session} do
    session
    |> visit("/elixir/medals")
    |> assert_has(Query.css(".champion-item", count: 3))
  end

  test "filtering medals by sport", context do
    context[:session]
    |> visit("/elixir/medals")
    |> click(Query.text("Toutes les disciplines"))
    |> click(Query.option("Ski de fond"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 2))
      |> assert_has(Query.attribute("title", "Argent"))
      |> assert_has(Query.text("Cl. général"))
      |> assert_has(Query.text(context[:champion1].first_name, count: 2))
    end)

    context[:session]
    |> click(Query.option("Combiné nordique"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 1))
      |> assert_has(Query.text(context[:champion2].first_name))
      |> assert_has(Query.attribute("title", "Bronze"))
    end)
  end

  test "filtering medals by sport and medals", %{session: session, champion1: champion1} do
    session
    |> visit("/elixir/medals")
    |> click(Query.option("Toutes les disciplines"))
    |> click(Query.option("Ski de fond"))
    |> click(Query.option("Toutes les spécialités"))
    |> click(Query.option("Poursuite"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 1))
      |> assert_has(Query.attribute("title", "Argent"))
      |> assert_has(Query.text("1992"))
      |> assert_has(Query.text(champion1.first_name, count: 1))
    end)

    session
    |> click(Query.option("Toutes les spécialités"))
    |> assert_has(Query.css(".champion-item", count: 2))
  end

  test "filtering medals by sport and year", %{session: session} do
    session
    |> visit("/elixir/medals")
    |> click(Query.option("Toutes les disciplines"))
    |> click(Query.option("Ski de fond"))
    |> click(Query.option("Toutes les années"))
    |> click(Query.option("1992"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 1))
      |> assert_has(Query.attribute("title", "Argent"))
      |> assert_has(Query.text("1992"))
    end)

    session
    |> click(Query.option("1981"))
    |> find(Query.css("#medals-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 1))
      |> assert_has(Query.attribute("title", "Or"))
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
    |> visit("/elixir/medals")
    |> click(Query.option("Ski de fond"))
    |> click(Query.text(champion1.first_name, count: 2, at: 1))
    |> assert_has(Query.text("Expériences professionnelles"))

    assert(
      String.ends_with?(
        current_url(session),
        "/champions/" <> to_string(champion1.id)
      )
    )
  end
end
