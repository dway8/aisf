defmodule AisfWeb.MembersTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

  setup do
    {:ok, champion1} = Factory.create_champion_with(%{is_member: true, sport: "Ski alpin"})
    {:ok, champion2} = Factory.create_champion_with(%{is_member: true, sport: "Biathlon"})
    {:ok, champion3} = Factory.create_champion_with(%{sport: "Ski alpin"})

    {:ok, champion1: champion1, champion2: champion2, champion3: champion3}
  end

  test "viewing a list of all the champions", context do
    context.session
    |> visit("/elixir/champions")
    |> assert_has(Query.css(".champion-item", count: 3))
    |> assert_has(Query.text(context.champion1.first_name))
    |> assert_has(Query.text(context.champion2.first_name))
    |> assert_has(Query.text(context.champion3.first_name))
  end

  test "filtering champions by sport", %{
    session: session,
    champion1: champion1,
    champion2: champion2,
    champion3: champion3
  } do
    session
    |> visit("/elixir/champions")
    |> assert_has(Query.css(".champion-item", count: 3))
    |> click(Query.text("Toutes les disciplines"))
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
    |> visit("/elixir/champions")
    |> click(Query.text(champion1.first_name))
    |> assert_has(Query.text("Expériences professionnelles"))

    assert(
      String.ends_with?(
        current_url(session),
        "/champions/" <> to_string(champion1.id)
      )
    )
  end
end
