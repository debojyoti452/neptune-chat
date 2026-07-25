defmodule NeptuneBackend.Relay.EventValidator do
  alias NeptuneBackend.Relay.Event

  @ephemeral_kinds 20_000..29_999
  @max_content_bytes 65_536

  def validate(raw_map) do
    with {:ok, event} <- parse(raw_map),
         :ok <- validate_kind(event.kind),
         :ok <- validate_content_size(event.content),
         :ok <- validate_id(event),
         :ok <- validate_signature(event) do
      {:ok, event}
    end
  end

  defp parse(map) do
    with {:ok, id} <- fetch_string(map, "id"),
         {:ok, pubkey} <- fetch_string(map, "pubkey"),
         {:ok, created_at} <- fetch_integer(map, "created_at"),
         {:ok, kind} <- fetch_integer(map, "kind"),
         {:ok, tags} <- fetch_list(map, "tags"),
         {:ok, content} <- fetch_string(map, "content"),
         {:ok, sig} <- fetch_string(map, "sig") do
      {:ok,
       %Event{
         id: id,
         pubkey: pubkey,
         created_at: created_at,
         kind: kind,
         tags: tags,
         content: content,
         sig: sig
       }}
    end
  end

  defp validate_kind(kind) when kind in @ephemeral_kinds, do: :ok
  defp validate_kind(_), do: {:error, "unsupported: kind not in ephemeral range 20000-29999"}

  defp validate_content_size(content) do
    if byte_size(content) <= @max_content_bytes do
      :ok
    else
      {:error, "invalid: content exceeds 64KB limit"}
    end
  end

  defp validate_id(%Event{} = event) do
    canonical = canonical_json(event)
    computed = :crypto.hash(:sha256, canonical) |> Base.encode16(case: :lower)

    if computed == event.id do
      :ok
    else
      {:error, "invalid: event id does not match content hash"}
    end
  end

  defp validate_signature(%Event{id: id, pubkey: pubkey, sig: sig}) do
    with {:ok, id_bytes} <- hex_decode(id, 32),
         {:ok, pubkey_bytes} <- hex_decode(pubkey, 32),
         {:ok, sig_bytes} <- hex_decode(sig, 64),
         :ok <- NeptuneBackend.Crypto.Schnorr.verify(id_bytes, sig_bytes, pubkey_bytes) do
      :ok
    else
      {:error, reason} when is_binary(reason) ->
        {:error, "invalid: signature verification failed - #{reason}"}

      _ ->
        {:error, "invalid: signature verification failed"}
    end
  end

  defp canonical_json(%Event{
         pubkey: pubkey,
         created_at: created_at,
         kind: kind,
         tags: tags,
         content: content
       }) do
    Jason.encode!([0, pubkey, created_at, kind, tags, content])
  end

  defp hex_decode(hex, expected_size) do
    case Base.decode16(hex, case: :lower) do
      {:ok, bytes} when byte_size(bytes) == expected_size -> {:ok, bytes}
      {:ok, _} -> {:error, "unexpected byte length for #{expected_size}-byte field"}
      :error -> {:error, "invalid hex encoding"}
    end
  end

  defp fetch_string(map, key) do
    case Map.get(map, key) do
      val when is_binary(val) -> {:ok, val}
      _ -> {:error, "invalid: missing or non-string field '#{key}'"}
    end
  end

  defp fetch_integer(map, key) do
    case Map.get(map, key) do
      val when is_integer(val) -> {:ok, val}
      _ -> {:error, "invalid: missing or non-integer field '#{key}'"}
    end
  end

  defp fetch_list(map, key) do
    case Map.get(map, key) do
      val when is_list(val) -> {:ok, val}
      _ -> {:error, "invalid: missing or non-list field '#{key}'"}
    end
  end
end
