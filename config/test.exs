use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :aisf, AisfWeb.Endpoint,
  http: [port: 4002],
  server: true

config :aisf, :sql_sandbox, true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :aisf, Aisf.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "aisf_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Chrome
config :wallaby,
  # chrome: [headless: false],
  driver: Wallaby.Experimental.Chrome,
  chromedriver: "/home/diane/Spottt/devops/scripts/ressources/chromedriver",
  screenshot_on_failure: true

# max_wait_time: 20_000
