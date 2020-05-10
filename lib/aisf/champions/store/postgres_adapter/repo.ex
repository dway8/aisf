defmodule Aisf.Champions.Store.PostgresAdapter.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :aisf,
    adapter: Ecto.Adapters.Postgres
end
