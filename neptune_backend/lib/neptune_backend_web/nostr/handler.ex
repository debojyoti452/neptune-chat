defmodule NeptuneBackendWeb.Nostr.Handler do
  @behaviour WebSock

  alias NeptuneBackendWeb.Nostr.MessageParser
  alias NeptuneBackend.Relay
  alias NeptuneBackend.Relay.{Event, Subscription}

  @max_subscriptions 20
  @rate_limit_window_ms 1_000
  @rate_limit_max_events 10

  @impl WebSock
  def init(state) do
    {:ok, Map.merge(state, %{subscriptions: %{}, subscribed_pubkeys: MapSet.new()})}
  end

  @impl WebSock
  def handle_in({data, [opcode: :text]}, state) do
    case MessageParser.parse(data) do
      {:event, raw_event} -> process_event(raw_event, state)
      {:req, sub_id, filters} -> process_req(sub_id, filters, state)
      {:close, sub_id} -> process_close(sub_id, state)
      {:error, reason} -> push_notice(reason, state)
    end
  end

  def handle_in(_, state), do: {:ok, state}

  @impl WebSock
  def handle_info({:nostr_event, %Event{} = event}, state) do
    matching = find_matching_subs(event, state.subscriptions)

    messages =
      Enum.map(matching, fn sub_id ->
        {:text, Jason.encode!(["EVENT", sub_id, event_to_map(event)])}
      end)

    case messages do
      [] -> {:ok, state}
      _ -> {:push, messages, state}
    end
  end

  def handle_info(_, state), do: {:ok, state}

  @impl WebSock
  def terminate(_reason, state) do
    Enum.each(state.subscribed_pubkeys, &Relay.unsubscribe/1)
    :ok
  end

  defp process_event(raw_event, state) do
    pubkey = Map.get(raw_event, "pubkey", "unknown")
    event_id = Map.get(raw_event, "id", "")

    case Hammer.check_rate(
           "nostr:events:#{pubkey}",
           @rate_limit_window_ms,
           @rate_limit_max_events
         ) do
      {:deny, _} ->
        response = Jason.encode!(["OK", event_id, false, "rate-limited: slow down"])
        {:push, [{:text, response}], state}

      {:allow, _} ->
        case Relay.validate_event(raw_event) do
          {:ok, event} ->
            Relay.broadcast(event)
            response = Jason.encode!(["OK", event.id, true, ""])
            {:push, [{:text, response}], state}

          {:error, reason} ->
            response = Jason.encode!(["OK", event_id, false, reason])
            {:push, [{:text, response}], state}
        end
    end
  end

  defp process_req(sub_id, filters, state) do
    if map_size(state.subscriptions) >= @max_subscriptions do
      response = Jason.encode!(["CLOSED", sub_id, "rate-limited: too many open subscriptions"])
      {:push, [{:text, response}], state}
    else
      subscription = build_subscription(sub_id, filters)
      new_pubkeys = subscribe_to_p_tags(subscription, state.subscribed_pubkeys)

      new_state =
        %{
          state
          | subscriptions: Map.put(state.subscriptions, sub_id, subscription),
            subscribed_pubkeys: MapSet.union(state.subscribed_pubkeys, new_pubkeys)
        }

      eose = Jason.encode!(["EOSE", sub_id])
      {:push, [{:text, eose}], new_state}
    end
  end

  defp process_close(sub_id, state) do
    new_state = %{state | subscriptions: Map.delete(state.subscriptions, sub_id)}
    {:ok, new_state}
  end

  defp push_notice(message, state) do
    {:push, [{:text, Jason.encode!(["NOTICE", message])}], state}
  end

  defp build_subscription(sub_id, filters) do
    merged = Enum.reduce(filters, %{}, &Map.merge(&2, &1))

    %Subscription{
      sub_id: sub_id,
      kinds: Map.get(merged, "kinds", []),
      authors: Map.get(merged, "authors", []),
      p_tags: Map.get(merged, "#p", [])
    }
  end

  defp subscribe_to_p_tags(%Subscription{p_tags: p_tags}, already_subscribed) do
    new_pubkeys = Enum.reject(p_tags, &MapSet.member?(already_subscribed, &1))
    Enum.each(new_pubkeys, &Relay.subscribe/1)
    MapSet.new(new_pubkeys)
  end

  defp find_matching_subs(event, subscriptions) do
    subscriptions
    |> Enum.filter(fn {_id, sub} -> matches_subscription?(event, sub) end)
    |> Enum.map(fn {sub_id, _} -> sub_id end)
  end

  defp matches_subscription?(event, %Subscription{kinds: kinds, authors: authors, p_tags: p_tags}) do
    kind_match = kinds == [] or event.kind in kinds
    author_match = authors == [] or event.pubkey in authors

    p_tag_match =
      p_tags == [] or
        Enum.any?(p_tags, fn p ->
          Enum.any?(event.tags, fn
            ["p", ^p | _] -> true
            _ -> false
          end)
        end)

    kind_match and author_match and p_tag_match
  end

  defp event_to_map(%Event{} = event) do
    %{
      "id" => event.id,
      "pubkey" => event.pubkey,
      "created_at" => event.created_at,
      "kind" => event.kind,
      "tags" => event.tags,
      "content" => event.content,
      "sig" => event.sig
    }
  end
end
