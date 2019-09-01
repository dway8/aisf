alias Aisf.Champions.Champion
alias Aisf.Sport
alias Aisf.ProExperiences.ProExperience
alias Aisf.Repo

sports = [
  "Ski alpin",
  "Ski de fond",
  "Biathlon",
  "Combiné nordique",
  "Freestyle",
  "Saut",
  "Snowboard"
]

for sport <- sports do
  %Sport{name: sport}
  |> Repo.insert!()
end

%Champion{
  last_name: "Pipitsu",
  first_name: "Rowena",
  email: "rowena@pipitsu.com",
  password: "azeaze",
  sport_id: 1
}
|> Repo.insert!()

%Champion{
  last_name: "Allais",
  first_name: "Emile",
  email: "allais@hotmail.com",
  password: "azeaze",
  sport_id: 2
}
|> Repo.insert!()

%ProExperience{
  occupational_category: "Hôtellerie",
  title: "Directeur",
  company_name: "Select",
  description: "Bla bla",
  website: "www.truc.fr",
  contact: "Mme Michu",
  champion_id: 1
}
|> Repo.insert!()

%ProExperience{
  occupational_category: "Hôtellerie",
  title: "Directeur",
  company_name: "Select",
  description: "Bla bla",
  website: "www.truc.fr",
  contact: "Mme Michu",
  champion_id: 2
}
|> Repo.insert!()
