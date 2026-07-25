defmodule NeptuneBackend.Relay do
  alias NeptuneBackend.Relay.{EventValidator, EventRouter}

  def validate_event(raw_map) do
    EventValidator.validate(raw_map)
  end

  def broadcast(event) do
    EventRouter.broadcast(event)
  end

  def subscribe(pubkey) do
    EventRouter.subscribe(pubkey)
  end

  def unsubscribe(pubkey) do
    EventRouter.unsubscribe(pubkey)
  end
end
