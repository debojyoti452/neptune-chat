defmodule NeptuneBackendWeb.Nostr.MessageParserTest do
  use ExUnit.Case, async: true

  alias NeptuneBackendWeb.Nostr.MessageParser

  describe "parse/1 - EVENT" do
    test "parses a valid EVENT message" do
      event = %{"id" => "abc", "pubkey" => "def", "kind" => 20001}
      json = Jason.encode!(["EVENT", event])
      assert MessageParser.parse(json) == {:event, event}
    end

    test "rejects EVENT with non-map payload" do
      json = Jason.encode!(["EVENT", "not_a_map"])
      assert {:error, _} = MessageParser.parse(json)
    end
  end

  describe "parse/1 - REQ" do
    test "parses REQ with no filters" do
      json = Jason.encode!(["REQ", "sub1"])
      assert MessageParser.parse(json) == {:req, "sub1", []}
    end

    test "parses REQ with filters" do
      filter = %{"kinds" => [20001], "#p" => ["pubkey1"]}
      json = Jason.encode!(["REQ", "sub1", filter])
      assert MessageParser.parse(json) == {:req, "sub1", [filter]}
    end

    test "parses REQ with multiple filters" do
      f1 = %{"kinds" => [20001]}
      f2 = %{"#p" => ["pk"]}
      json = Jason.encode!(["REQ", "sub1", f1, f2])
      assert MessageParser.parse(json) == {:req, "sub1", [f1, f2]}
    end

    test "rejects REQ with non-string sub_id" do
      json = Jason.encode!(["REQ", 123])
      assert {:error, _} = MessageParser.parse(json)
    end
  end

  describe "parse/1 - CLOSE" do
    test "parses a valid CLOSE message" do
      json = Jason.encode!(["CLOSE", "sub1"])
      assert MessageParser.parse(json) == {:close, "sub1"}
    end

    test "rejects CLOSE with non-string sub_id" do
      json = Jason.encode!(["CLOSE", 99])
      assert {:error, _} = MessageParser.parse(json)
    end
  end

  describe "parse/1 - errors" do
    test "returns error for malformed JSON" do
      assert {:error, "invalid: malformed JSON"} = MessageParser.parse("{not json}")
    end

    test "returns error for unknown message type" do
      json = Jason.encode!(["UNKNOWN", "data"])
      assert {:error, "invalid: unrecognised message type"} = MessageParser.parse(json)
    end

    test "returns error for non-array payload" do
      json = Jason.encode!(%{"type" => "EVENT"})
      assert {:error, "invalid: unrecognised message type"} = MessageParser.parse(json)
    end
  end
end
