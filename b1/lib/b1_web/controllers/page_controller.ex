defmodule B1Web.PageController do
  use B1Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
