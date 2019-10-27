defmodule AisfWeb.TeamsTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

  setup do
    {:ok, champion1} =
      Factory.create_champion_with(%{sport: "Saut", years_in_french_team: [1973, 1999, 2018]})

    {:ok, champion2} =
      Factory.create_champion_with(%{sport: "Snowboard", years_in_french_team: [2000, 2002]})

    {:ok, _champion3} = Factory.create_champion_with(%{sport: "Freestyle"})

    {:ok, champion1: champion1, champion2: champion2}
  end

  test "viewing all the champions with years in french team when no year selected", context do
    context[:session]
    |> visit("/elixir/teams")
    |> assert_has(Query.css("#teams-list"))
    |> assert_has(Query.css(".champion-item", count: 5))
    |> assert_has(Query.text(context[:champion1].first_name, count: 3))
    |> assert_has(Query.text(context[:champion2].first_name, count: 2))
  end

  test "filtering champions by sport", context do
    context.session
    |> visit("/elixir/teams")
    |> click(Query.option("Toutes les disciplines"))
    |> click(Query.option("Saut"))
    |> find(Query.css("#teams-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 3))
      |> assert_has(Query.text(context.champion1.first_name, count: 3))
      |> assert_has(Query.text("1973"))
      |> assert_has(Query.text("1999"))
      |> assert_has(Query.text("2018"))
    end)

    context.session
    |> click(Query.option("Freestyle"))
    |> find(Query.css("#teams-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 0))
    end)

    context.session
    |> click(Query.option("Toutes les disciplines"))
    |> find(Query.css("#teams-list"), fn element ->
      element
      |> assert_has(Query.css(".champion-item", count: 5))
    end)
  end

  test "filtering champions by year", context do
    context.session
    |> visit("/elixir/teams")
    |> click(Query.option("Toutes les années"))
    |> click(Query.option("1999"))
    |> assert_has(Query.css(".champion-item", count: 1))
    |> assert_has(Query.text(context.champion1.first_name, count: 1))
    |> click(Query.option("Toutes les années"))
    |> assert_has(Query.css(".champion-item", count: 5))
  end

  test "filtering champions by sport and year", context do
    context.session
    |> visit("/elixir/teams")
    |> click(Query.option("Toutes les disciplines"))
    |> click(Query.option("Snowboard"))
    |> click(Query.option("Toutes les années"))
    |> click(Query.option("2018"))
    |> assert_has(Query.css(".champion-item", count: 0))
    |> click(Query.option("1973"))
    |> assert_has(Query.css(".champion-item", count: 0))
    |> click(Query.option("Saut"))
    |> assert_has(Query.css(".champion-item", count: 1))
    |> assert_has(Query.text(context.champion1.first_name))
  end

  test "selecting a champion in the list", %{session: session, champion2: champion2} do
    session
    |> visit("/elixir/teams")
    |> click(Query.option("Snowboard"))
    |> click(Query.text(champion2.first_name, count: 2, at: 1))
    |> assert_has(Query.text("Expériences professionnelles"))

    assert(
      String.ends_with?(
        current_url(session),
        "/champions/" <> to_string(champion2.id)
      )
    )
  end
end
