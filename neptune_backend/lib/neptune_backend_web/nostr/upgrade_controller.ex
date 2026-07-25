defmodule NeptuneBackendWeb.Nostr.UpgradeController do
  use NeptuneBackendWeb, :controller

  def connect(conn, _params) do
    WebSockAdapter.upgrade(conn, NeptuneBackendWeb.Nostr.Handler, %{}, timeout: :infinity)
  end
end
