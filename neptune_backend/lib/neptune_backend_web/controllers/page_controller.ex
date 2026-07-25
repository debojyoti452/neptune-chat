defmodule NeptuneBackendWeb.PageController do
  use NeptuneBackendWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
