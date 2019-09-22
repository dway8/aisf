defmodule AisfWeb.FilterChampionsTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

  @filter_input Query.text_field("Rechercher un champion")

  setup do
    {:ok, champion1} = Factory.create_champion_with_name("Diane", "Truc")
    {:ok, champion2} = Factory.create_champion_with_name("Paul", "Dupont")
    {:ok, champion3} = Factory.create_champion_with_name("Paule", "Bidule")
    {:ok, champion4} = Factory.create_champion_with_name("Jack", "Bauer")

    {:ok, champion1: champion1, champion2: champion2, champion3: champion3, champion4: champion4}
  end

  test "filtering champions by name", context do
    context.session
    |> visit("/champions")
    |> assert_has(Query.css(".champion-item", count: 4))
    |> fill_in(@filter_input, "Paul")
    |> assert_has(Query.css(".champion-item", count: 2))
    |> assert_has(Query.text(context.champion2.first_name))
    |> assert_has(Query.text(context.champion3.first_name))
  end

  test "filtering champions by name and sport", %{
    session: session,
    champion1: champion1,
    champion2: champion2,
    champion3: champion3
  } do
    session
    |> visit("/champions")
  end
end
