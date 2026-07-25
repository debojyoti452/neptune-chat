defmodule NeptuneBackendWeb.Router do
  use NeptuneBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NeptuneBackendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug NeptuneBackendWeb.Plugs.AuthPlug
  end

  scope "/", NeptuneBackendWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/", NeptuneBackendWeb do
    get "/nostr", Nostr.UpgradeController, :connect
  end

  scope "/api/v1", NeptuneBackendWeb do
    pipe_through :api

    get "/health", HealthController, :index
    post "/auth/register", AuthController, :register

    scope "/" do
      pipe_through :authenticated

      post "/auth/revoke", AuthController, :revoke
      get "/peers/:pubkey/hints", PeerController, :hints
      put "/peers/me/hints", PeerController, :announce
    end
  end

  if Application.compile_env(:neptune_backend, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NeptuneBackendWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
