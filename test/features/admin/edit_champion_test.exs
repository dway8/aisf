defmodule AisfWeb.Admin.EditChampionTest do
  use AisfWeb.FeatureCase, async: true
  alias AisfWeb.Factory

  @save_champion_button Query.css("#save-champion-btn")

  setup(context) do
    {:ok, champion} = Factory.create_champion_with(%{sport: "Ski alpin"})

    context.session
    |> visit("/elixir/")
    |> set_cookie("isAdmin", "1")

    {:ok, champion: champion}
  end

  test "editing a champion's presentation", %{session: session, champion: champion} do
    session
    |> visit("/elixir/champions/" <> to_string(champion.id))
    |> assert_has(Query.text("Modifier", count: 6))
    |> assert_has(Query.text(champion.first_name))
    |> click(Query.text("Modifier", count: 6) |> Query.at(0))
    |> has_value?(Query.text_field("Prénom"), champion.first_name)

    session
    |> fill_in(Query.text_field("Prénom"), with: "Diane")
    |> click(@save_champion_button)
    |> assert_has(Query.text("Modifier", count: 6))
    |> refute_has(@save_champion_button)
    |> assert_has(Query.text("Diane"))

    assert(
      String.ends_with?(
        current_url(session),
        "/champions/" <> to_string(champion.id)
      )
    )
  end

  test "adding a pro experience" do
  end

  test "editing a medal" do
  end

  test "removing a medal" do
  end
end
