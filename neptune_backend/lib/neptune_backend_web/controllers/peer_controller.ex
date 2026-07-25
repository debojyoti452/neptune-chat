defmodule NeptuneBackendWeb.PeerController do
  use NeptuneBackendWeb, :controller

  alias NeptuneBackend.Signaling

  def hints(conn, %{"pubkey" => pubkey}) do
    case Signaling.get_hints(pubkey) do
      {:ok, hint} -> render(conn, :hints, hint: hint)
      {:error, :not_found} -> send_resp(conn, :not_found, "")
    end
  end

  def announce(conn, params) do
    user = conn.assigns.current_user

    attrs = %{
      ip: params["ip"],
      port: params["port"],
      transports: params["transports"] || []
    }

    Signaling.announce(user.pubkey, attrs)
    send_resp(conn, :no_content, "")
  end
end
