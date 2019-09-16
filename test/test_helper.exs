ExUnit.start()
Faker.start()

Ecto.Adapters.SQL.Sandbox.mode(Aisf.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)

Application.put_env(:wallaby, :base_url, AisfWeb.Endpoint.url())
