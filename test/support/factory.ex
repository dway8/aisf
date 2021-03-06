defmodule AisfWeb.Factory do
  alias Aisf.Champions
  alias Aisf.Champions.Champion
  alias Aisf.Medals.Medals

  @sports Champion.sports()

  def create_champion_with(attrs) do
    champion =
      %{
        last_name: Faker.Name.last_name(),
        first_name: Faker.Name.first_name(),
        # email: Faker.Internet.free_email(),
        sport: Enum.random(@sports),
        # years_in_french_team: [],
        # pro_experiences: [],
        # medals: [],
        is_member: false
        # intro: Faker.Lorem.paragraph(Enum.random(2..5)),
        # highlights: []
      }
      |> Map.merge(attrs)

    Champions.create_champion(champion)
  end

  def create_medals_for_champion(champion, medals) do
    Enum.each(medals, fn m ->
      Medals.create_medal(champion, m)
    end)
  end

  def update_sport_career(champion, attrs) do
    Champions.update_sport_career(champion, attrs)
  end
end
