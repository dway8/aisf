defmodule AisfWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias Aisf.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import AisfWeb.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aisf.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Aisf.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Aisf.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
