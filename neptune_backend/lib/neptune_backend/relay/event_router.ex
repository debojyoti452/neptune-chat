defmodule NeptuneBackend.Relay.EventRouter do
  alias NeptuneBackend.Relay.Event

  @pubsub NeptuneBackend.PubSub

  def broadcast(%Event{} = event) do
    event.tags
    |> extract_p_tags()
    |> Enum.each(fn pubkey ->
      Phoenix.PubSub.broadcast(@pubsub, topic(pubkey), {:nostr_event, event})
    end)

    :ok
  end

  def subscribe(pubkey) do
    Phoenix.PubSub.subscribe(@pubsub, topic(pubkey))
  end

  def unsubscribe(pubkey) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(pubkey))
  end

  defp topic(pubkey), do: "relay:p:#{pubkey}"

  defp extract_p_tags(tags) do
    tags
    |> Enum.filter(fn
      ["p", _pubkey | _] -> true
      _ -> false
    end)
    |> Enum.map(fn ["p", pubkey | _] -> pubkey end)
    |> Enum.uniq()
  end
end
