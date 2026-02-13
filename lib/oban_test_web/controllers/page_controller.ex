defmodule ObanTestWeb.PageController do
  use ObanTestWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
