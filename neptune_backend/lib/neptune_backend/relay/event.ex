defmodule NeptuneBackend.Relay.Event do
  @enforce_keys [:id, :pubkey, :created_at, :kind, :tags, :content, :sig]
  defstruct [:id, :pubkey, :created_at, :kind, :tags, :content, :sig]
end
