defmodule AisfWeb.PageController do
  use AisfWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
