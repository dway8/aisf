defmodule AisfWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :aisf

  socket "/socket", AisfWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket

  if Application.get_env(:aisf, :sql_sandbox) do
    plug Phoenix.Ecto.SQL.Sandbox
  end

  # Serve at "/" the static files from "priv/static" directory.
  #
  #
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/elixir/resources",
    from: :aisf,
    gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt)

  plug Plug.Static,
    at: "/elixir/uploads",
    from: Path.expand(Application.get_env(:aisf, AisfWeb.Endpoint)[:upload_dir]),
    gzip: true

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_aisf_key",
    signing_salt: "UV6WBFTZ"

  plug AisfWeb.Router
end
