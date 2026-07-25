defmodule NeptuneBackendWeb.Nostr.MessageParser do
  def parse(raw_json) when is_binary(raw_json) do
    case Jason.decode(raw_json) do
      {:ok, payload} -> parse_payload(payload)
      {:error, _} -> {:error, "invalid: malformed JSON"}
    end
  end

  defp parse_payload(["EVENT", event]) when is_map(event) do
    {:event, event}
  end

  defp parse_payload(["REQ", sub_id | filters])
       when is_binary(sub_id) and is_list(filters) do
    {:req, sub_id, filters}
  end

  defp parse_payload(["CLOSE", sub_id]) when is_binary(sub_id) do
    {:close, sub_id}
  end

  defp parse_payload(_), do: {:error, "invalid: unrecognised message type"}
end
