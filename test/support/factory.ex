defmodule AisfWeb.Factory do
  alias Aisf.Champions

  def create_champion_with_sport(sport) do
    champion = %{
      last_name: Faker.Name.last_name(),
      first_name: Faker.Name.first_name(),
      email: Faker.Internet.free_email(),
      password: Faker.UUID.v4(),
      sport: sport,
      years_in_french_team: [],
      pro_experiences: [],
      medals: []
    }

    Champions.create_champion(champion)
  end

  def create_champion_with_sport_and_medals(sport, medals) do
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

  def create_champion_with_sport_and_years_in_french_team(sport, years) do
    champion = %{
      last_name: Faker.Name.last_name(),
      first_name: Faker.Name.first_name(),
      email: Faker.Internet.free_email(),
      password: Faker.UUID.v4(),
      sport: sport,
      years_in_french_team: years,
      pro_experiences: [],
      medals: []
    }

    Champions.create_champion(champion)
  end
end
