defmodule NeptuneBackendWeb.PeerJSON do
  def hints(%{hint: hint}) do
    %{
      pubkey: hint.pubkey,
      ip: hint.ip,
      port: hint.port,
      transports: hint.transports,
      seen_at: hint.seen_at
    }
  end
end
