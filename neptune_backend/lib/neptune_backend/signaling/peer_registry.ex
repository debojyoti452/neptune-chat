defmodule NeptuneBackend.Signaling.PeerRegistry do
  use GenServer

  alias NeptuneBackend.Signaling.PeerHint

  @table :peer_registry
  @ttl_seconds 300

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def announce(pubkey, attrs) do
    hint = %PeerHint{
      pubkey: pubkey,
      ip: attrs[:ip],
      port: attrs[:port],
      transports: attrs[:transports] || [],
      seen_at: DateTime.utc_now()
    }

    :ets.insert(@table, {pubkey, hint})
    :ok
  end

  def get(pubkey) do
    case :ets.lookup(@table, pubkey) do
      [{^pubkey, hint}] -> {:ok, hint}
      [] -> {:error, :not_found}
    end
  end

  def prune_stale do
    cutoff = DateTime.utc_now() |> DateTime.add(-@ttl_seconds, :second)

    @table
    |> :ets.tab2list()
    |> Enum.each(fn {pubkey, hint} ->
      if DateTime.compare(hint.seen_at, cutoff) == :lt do
        :ets.delete(@table, pubkey)
      end
    end)
  end

  @impl true
  def init(_opts) do
    :ets.new(@table, [:named_table, :public, :set, {:read_concurrency, true}])
    {:ok, %{}}
  end
end
