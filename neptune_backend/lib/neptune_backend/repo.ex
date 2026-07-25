defmodule NeptuneBackend.Repo do
  use Ecto.Repo,
    otp_app: :neptune_backend,
    adapter: Application.compile_env(:neptune_backend, :db_adapter, Ecto.Adapters.Postgres)
end
