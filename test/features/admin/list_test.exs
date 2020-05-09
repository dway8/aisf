defmodule AisfWeb.Admin.ListTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

  setup(context) do
    {:ok, champion1} = Factory.create_champion_with(%{is_member: true, sport: "Ski alpin"})
    {:ok, champion2} = Factory.create_champion_with(%{is_member: true, sport: "Biathlon"})
    {:ok, champion3} = Factory.create_champion_with(%{sport: "Ski alpin"})
    {:ok, champion4} = Factory.create_champion_with(%{sport: "Ski de fond"})

    context.session
    |> visit("/elixir/")
    |> set_cookie("isAdmin", "1")

    {:ok, champion1: champion1, champion2: champion2, champion3: champion3, champion4: champion4}
  end

  test "filtering champions by sport", %{
    session: session,
    champion1: champion1,
    champion2: champion2,
    champion3: champion3
  } do
    session
    |> visit("/elixir/")
    |> click(Query.option("Toutes les disciplines"))
    |> click(Query.option("Biathlon"))
    |> assert_has(Query.css(".champion-item", count: 1))
    |> assert_has(Query.text(champion2.first_name))
    |> click(Query.option("Ski alpin"))
    |> assert_has(Query.css(".champion-item", count: 2))
    |> assert_has(Query.text(champion1.first_name))
    |> assert_has(Query.text(champion3.first_name))
  end

  test "selecting a champion in the list goes to the full champion page", %{
    session: session,
    champion1: champion1
  } do
    session
    |> visit("/elixir/")
    |> click(Query.text(champion1.first_name))
    |> assert_has(Query.text("Modifier", count: 6))
    |> assert_has(Query.text("INFORMATIONS PRIVÉES"))
  end
end
