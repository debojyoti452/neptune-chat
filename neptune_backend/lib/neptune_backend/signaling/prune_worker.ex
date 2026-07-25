defmodule NeptuneBackend.Signaling.PruneWorker do
  use GenServer

  @interval_ms 60_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:prune, state) do
    NeptuneBackend.Signaling.PeerRegistry.prune_stale()
    NeptuneBackend.Auth.prune_expired()
    schedule()
    {:noreply, state}
  end

  defp schedule do
    Process.send_after(self(), :prune, @interval_ms)
  end
end
