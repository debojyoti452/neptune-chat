defmodule NeptuneBackend.Signaling.PeerHint do
  @enforce_keys [:pubkey, :transports, :seen_at]
  defstruct [:pubkey, :ip, :port, :transports, :seen_at]
end
