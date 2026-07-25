defmodule NeptuneBackend.Relay.Subscription do
  @enforce_keys [:sub_id]
  defstruct [:sub_id, kinds: [], authors: [], p_tags: []]
end
