defmodule AisfWeb.Admin.ListTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

  setup(context) do
    {:ok, champion1} = Factory.create_champion_with(%{is_member: true, sport: "Ski alpin"})
    {:ok, champion2} = Factory.create_champion_with(%{is_member: true, sport: "Biathlon"})
    {:ok, champion3} = Factory.create_champion_with(%{sport: "Ski alpin"})
    {:ok, champion4} = Factory.create_champion_with(%{sport: "Ski de fond"})

    context.session
    |> visit("/")
    |> set_cookie("isAdmin", "1")

    {:ok, champion1: champion1, champion2: champion2, champion3: champion3, champion4: champion4}
  end

  test "viewing a list of all the champions", context do
    context.session
    |> visit("/admin")
    |> assert_has(Query.css(".champion-item", count: 4))
    |> assert_has(Query.text(context.champion1.first_name))
    |> assert_has(Query.text(context.champion2.first_name))
    |> assert_has(Query.text(context.champion3.first_name))
    |> assert_has(Query.text(context.champion4.first_name))
  end

  test "filtering champions by sport", %{
    session: session,
    champion1: champion1,
    champion2: champion2,
    champion3: champion3
  } do
    session
    |> visit("/admin")
    |> click(Query.option("Toutes les disciplines"))
    |> click(Query.option("Biathlon"))
    |> assert_has(Query.css(".champion-item", count: 1))
    |> assert_has(Query.text(champion2.first_name))
    |> click(Query.option("Ski alpin"))
    |> assert_has(Query.css(".champion-item", count: 2))
    |> assert_has(Query.text(champion1.first_name))
    |> assert_has(Query.text(champion3.first_name))
  end

  test "selecting a champion in the list goes the champion edit page", %{
    session: session,
    champion1: champion1
  } do
    session
    |> visit("/admin")
    |> click(Query.text(champion1.first_name))
    |> assert_has(Query.text("ÉDITER CHAMPION"))

    assert(
      String.ends_with?(
        current_url(session),
        "/champions/edit/" <> to_string(champion1.id)
      )
    )
  end
end
