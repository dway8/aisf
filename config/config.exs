# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :aisf,
  ecto_repos: [Aisf.Repo]

# Configures the endpoint
config :aisf, AisfWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gdPkEUMweKVmottW7lFa93KQ3sZ4x9AMBCvA/2e6BJGVJFzurTxzyNb+FqyIGEWh",
  render_errors: [view: AisfWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Aisf.PubSub,
  live_view: [signing_salt: "VXsTvCkavlacgzklD73ofe3MTTitgGiX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
