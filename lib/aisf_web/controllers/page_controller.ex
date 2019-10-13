defmodule AisfWeb.PageController do
  use AisfWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",
      admin_cookie: Application.get_env(:aisf, AisfWeb.Endpoint)[:admin_cookie]
    )
  end
end
