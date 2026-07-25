import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/neptune_backend start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :neptune_backend, NeptuneBackendWeb.Endpoint, server: true
end

config :neptune_backend, NeptuneBackendWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

if config_env() == :dev do
  # Reload browser tabs when matching files change.
  config :neptune_backend, NeptuneBackendWeb.Endpoint,
    live_reload: [
      web_console_logger: true,
      patterns: [
        # Static assets, except user uploads
        ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
        # Gettext translations
        ~r"priv/gettext/.*\.po$"E,
        # Router, Controllers, LiveViews and LiveComponents
        ~r"lib/neptune_backend_web/router\.ex$"E,
        ~r"lib/neptune_backend_web/(controllers|live|components)/.*\.(ex|heex)$"E
      ]
    ]
end

if config_env() == :prod do
  adapter = Application.get_env(:neptune_backend, :db_adapter, Ecto.Adapters.Postgres)

  cond do
    adapter == Ecto.Adapters.SQLite3 ->
      sqlite_path = System.get_env("SQLITE_DB_PATH", "priv/neptune.db")

      config :neptune_backend, NeptuneBackend.Repo,
        database: sqlite_path,
        pool_size: 1

    true ->
      database_url =
        System.get_env("DATABASE_URL") ||
          raise """
          DATABASE_URL is required for PostgreSQL deployments.
          Example: ecto://USER:PASS@HOST/DATABASE

          To use SQLite instead, build with: NEPTUNE_DB_ADAPTER=sqlite mix release
          """

      maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

      config :neptune_backend, NeptuneBackend.Repo,
        url: database_url,
        pool_size: String.to_integer(System.get_env("POOL_SIZE", "10")),
        socket_options: maybe_ipv6
  end

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      SECRET_KEY_BASE is missing. Generate one with: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"

  config :neptune_backend, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :neptune_backend, NeptuneBackendWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :neptune_backend, NeptuneBackendWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://plug.hexdocs.pm/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :neptune_backend, NeptuneBackendWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Here is an example configuration for Mailgun:
  #
  #     config :neptune_backend, NeptuneBackend.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # Most non-SMTP adapters require an API client. Swoosh supports Req, Hackney,
  # and Finch out-of-the-box. This configuration is typically done at
  # compile-time in your config/prod.exs:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Req
  #
  # See https://swoosh.hexdocs.pm/Swoosh.html#module-installation for details.
end
