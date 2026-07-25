defmodule NeptuneBackend.Relay.EventValidatorTest do
  use ExUnit.Case, async: true

  alias NeptuneBackend.Relay.EventValidator

  @valid_event %{
    "id" => "3e8c1af8e012e9fc4f2a19f9a1eb37d89374d4feef3a2f08e86b32dea3c6f3f1",
    "pubkey" => "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
    "created_at" => 1_700_000_000,
    "kind" => 20001,
    "tags" => [],
    "content" => "hello",
    "sig" => String.duplicate("a", 128)
  }

  describe "validate/1 - field parsing" do
    test "rejects missing id" do
      map = Map.delete(@valid_event, "id")
      assert {:error, "invalid: missing or non-string field 'id'"} = EventValidator.validate(map)
    end

    test "rejects non-string pubkey" do
      map = Map.put(@valid_event, "pubkey", 123)

      assert {:error, "invalid: missing or non-string field 'pubkey'"} =
               EventValidator.validate(map)
    end

    test "rejects non-integer created_at" do
      map = Map.put(@valid_event, "created_at", "now")

      assert {:error, "invalid: missing or non-integer field 'created_at'"} =
               EventValidator.validate(map)
    end

    test "rejects non-list tags" do
      map = Map.put(@valid_event, "tags", "bad")
      assert {:error, "invalid: missing or non-list field 'tags'"} = EventValidator.validate(map)
    end
  end

  describe "validate/1 - kind" do
    test "rejects kind outside ephemeral range" do
      map = Map.put(@valid_event, "kind", 1)

      assert {:error, "unsupported: kind not in ephemeral range 20000-29999"} =
               EventValidator.validate(map)
    end

    test "rejects kind 30000" do
      map = Map.put(@valid_event, "kind", 30000)

      assert {:error, "unsupported: kind not in ephemeral range 20000-29999"} =
               EventValidator.validate(map)
    end

    test "accepts kind 20000" do
      map = Map.put(@valid_event, "kind", 20000)
      assert match?({:error, _}, EventValidator.validate(map))
      refute match?({:error, "unsupported:" <> _}, EventValidator.validate(map))
    end
  end

  describe "validate/1 - content size" do
    test "rejects content exceeding 64KB" do
      map = Map.put(@valid_event, "content", String.duplicate("x", 65_537))
      assert {:error, "invalid: content exceeds 64KB limit"} = EventValidator.validate(map)
    end

    test "accepts content at exactly 64KB" do
      map = Map.put(@valid_event, "content", String.duplicate("x", 65_536))
      refute match?({:error, "invalid: content exceeds 64KB limit"}, EventValidator.validate(map))
    end
  end

  describe "validate/1 - id verification" do
    test "rejects event where id does not match content hash" do
      map = Map.put(@valid_event, "content", "tampered")

      assert {:error, "invalid: event id does not match content hash"} =
               EventValidator.validate(map)
    end
  end
end
