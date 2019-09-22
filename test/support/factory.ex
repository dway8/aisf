defmodule AisfWeb.Factory do
  alias Aisf.Champions
  alias Aisf.Champions.Champion

  @sports Champion.sports()

  def create_champion_with_sport(sport) do
    create_champion_with_membership_and_sport(false, sport)
  end

  def create_champion_with_membership_and_sport(is_member, sport) do
    champion = %{
      last_name: Faker.Name.last_name(),
      first_name: Faker.Name.first_name(),
      email: Faker.Internet.free_email(),
      password: Faker.UUID.v4(),
      sport: sport,
      years_in_french_team: [],
      pro_experiences: [],
      medals: [],
      is_member: is_member,
      intro: Faker.Lorem.paragraph(Enum.random(2..5))
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
      medals: medals,
      is_member: false,
      intro: Faker.Lorem.paragraph(Enum.random(2..5))
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
      medals: [],
      is_member: false,
      intro: Faker.Lorem.paragraph(Enum.random(2..5))
    }

    Champions.create_champion(champion)
  end

  def create_champion_with_name(first_name, last_name) do
    champion = %{
      last_name: last_name,
      first_name: first_name,
      email: Faker.Internet.free_email(),
      password: Faker.UUID.v4(),
      sport: Enum.random(@sports),
      years_in_french_team: [],
      pro_experiences: [],
      medals: [],
      is_member: false,
      intro: Faker.Lorem.paragraph(Enum.random(2..5))
    }

    Champions.create_champion(champion)
  end
end
