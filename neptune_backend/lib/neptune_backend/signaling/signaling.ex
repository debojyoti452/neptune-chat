defmodule NeptuneBackend.Signaling do
  alias NeptuneBackend.Signaling.PeerRegistry

  def announce(pubkey, attrs) do
    PeerRegistry.announce(pubkey, attrs)
  end

  def get_hints(pubkey) do
    PeerRegistry.get(pubkey)
  end
end
