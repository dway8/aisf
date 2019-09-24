defmodule AisfWeb.FilterChampionsTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

  @filter_input Query.text_field("Rechercher un champion")

  setup do
    {:ok, champion1} =
      Factory.create_champion_with(%{first_name: "Diane", last_name: "Truc", is_member: true})

    {:ok, champion2} =
      Factory.create_champion_with(%{first_name: "Paul", last_name: "Dupont", is_member: true})

    {:ok, champion3} =
      Factory.create_champion_with(%{first_name: "Paule", last_name: "Bidule", is_member: true})

    {:ok, champion4} =
      Factory.create_champion_with(%{first_name: "Jack", last_name: "Bauer", is_member: true})

    {:ok, champion1: champion1, champion2: champion2, champion3: champion3, champion4: champion4}
  end

  test "filtering champions by name", context do
    context.session
    |> visit("/champions")
    |> assert_has(Query.css(".champion-item", count: 4))
    |> fill_in(@filter_input, with: "Paul")
    |> assert_has(Query.css(".champion-item", count: 2))
    |> assert_has(Query.text(String.upcase(context.champion2.last_name)))
    |> assert_has(Query.text(String.upcase(context.champion3.last_name)))
  end

  test "filtering champions by name and sport", context do
    context.session
    |> visit("/champions")
  end
end
