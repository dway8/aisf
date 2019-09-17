defmodule Aisf.DatabaseSeeder do
  alias Aisf.Champions.Champion
  alias Aisf.ProExperiences.ProExperience
  alias Aisf.Medals.Medal
  alias Aisf.Repo

  @numberOfChampions Enum.random(6..20)

  @sports Champion.sports()
  @years 1960..2019

  def insert_champions do
    Enum.each(1..@numberOfChampions, fn _i ->
      years_in_french_team = Enum.take_random(@years, Enum.random(0..10))
      sport = Enum.random(@sports)

      champion =
        %Champion{
          last_name: Faker.Name.last_name(),
          first_name: Faker.Name.first_name(),
          email: Faker.Internet.free_email(),
          password: Faker.UUID.v4(),
          sport: sport,
          years_in_french_team: years_in_french_team,
          is_member: Enum.random([true, false]),
          intro: Faker.Lorem.paragraph(Enum.random(2..5))
        }
        |> Repo.insert!()

      Enum.each(0..Enum.random(0..4), fn _i ->
        %ProExperience{
          occupational_category: Faker.Industry.sector(),
          title: Faker.Name.title(),
          company_name: Faker.Company.name(),
          description: Faker.Lorem.paragraph(3),
          website: Faker.Internet.url(),
          contact: Faker.Name.name(),
          champion_id: champion.id
        }
        |> Repo.insert!()
      end)

      Enum.each(0..Enum.random(0..6), fn _i ->
        %Medal{
          competition: Enum.random(["OlympicGames", "WorldChampionships", "WorldCup"]),
          medal_type: Enum.random(1..3),
          specialty: Enum.random(get_specialties_for_sport(sport)),
          year: Enum.random(@years),
          champion_id: champion.id
        }
        |> Repo.insert!()
      end)
    end)
  end

  defp get_specialties_for_sport(sport) do
    case sport do
      "Ski alpin" ->
        [
          "Slalom",
          "SlalomGeneral",
          "Descente",
          "DescenteGeneral",
          "SuperG",
          "SuperGGeneral",
          "SuperCombine",
          "SuperCombineGeneral",
          "Geant",
          "General",
          "Combine",
          "ParEquipe"
        ]

      "Ski de fond" ->
        [
          "Individuel",
          "IndividuelGeneral",
          "Sprint",
          "SprintGeneral",
          "Poursuite",
          "PoursuiteGeneral",
          "Relais",
          "RelaisGeneral",
          "SprintX2",
          "SprintX2General",
          "General"
        ]

      "Biathlon" ->
        [
          "Individuel",
          "IndividuelGeneral",
          "Sprint",
          "SprintGeneral",
          "Relais",
          "RelaisGeneral",
          "MassStart",
          "MassStartGeneral",
          "Poursuite",
          "PoursuiteGeneral",
          "SprintX2",
          "SprintX2General",
          "General"
        ]

      "Combiné nordique" ->
        [
          "Individuel",
          "IndividuelGeneral",
          "Poursuite",
          "PoursuiteGeneral",
          "ParEquipe",
          "ParEquipeGeneral",
          "General"
        ]

      "Freestyle" ->
        [
          "Bosses",
          "BossesGeneral",
          "SautBigAir",
          "SautBigAirGeneral",
          "SkiCross",
          "SkiCrossGeneral",
          "HalfPipe",
          "HalfPipeGeneral",
          "Slopestyle",
          "Acrobatique",
          "Artistique",
          "General"
        ]

      "Saut" ->
        ["SautSpecial", "SautSpecialGeneral", "VolASki", "VolASkiGeneral"]

      "Snowboard" ->
        [
          "Cross",
          "CrossGeneral",
          "SnowFreestyle",
          "SnowFreestyleGeneral",
          "SnowAlpin",
          "SnowAlpinGeneral",
          "HalfPipe",
          "HalfPipeGeneral",
          "SautBigAir",
          "Slopestyle",
          "General"
        ]
    end
  end
end

Aisf.DatabaseSeeder.insert_champions()
