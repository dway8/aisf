alias Aisf.Champions.Champion
alias Aisf.Repo

%Champion{
  last_name: "Pipitsu",
  first_name: "Rowena",
  email: "rowena@pipitsu.com",
  password: "azeaze"
}
|> Repo.insert!()

%Champion{
  last_name: "Allais",
  first_name: "Emile",
  email: "allais@hotmail.com",
  password: "azeaze"
}
|> Repo.insert!()
