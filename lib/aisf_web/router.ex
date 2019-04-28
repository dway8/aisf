defmodule AisfWeb.Router do
  use AisfWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :graphql do
    # plug(:accepts, ["json"])
  end

  # graphql API scope
  scope "/" do
    pipe_through(:graphql)
    forward("/graphql", Absinthe.Plug, schema: AisfWeb.Schema)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: AisfWeb.Schema,
      interface: :simple,
      context: %{pubsub: AisfWeb.Endpoint}
  end

  scope "/", AisfWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AisfWeb do
  #   pipe_through :api
  # end
end
