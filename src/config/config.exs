# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :payfy,
  ecto_repos: [Payfy.Repo]

config :payfy, Oban,
  repo: Payfy.Repo,
  plugins: [
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron,
     crontab: [
       {"* * * * *", Payfy.Workers.PokemonHungryWorker}
     ]}
  ],
  queues: [default: 10, events: 50, media: 20]

# Configures the endpoint
config :payfy, PayfyWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PayfyWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Payfy.PubSub,
  live_view: [signing_salt: "rIDZ8pyS"]

# Configures Tesla as Http Service
config :tesla, adapter: Tesla.Adapter.Httpc

config :payfy, Payfy.Guardian,
  issuer: "payfy",
  secret_key: "TV6aZxouQQHlMfNB6Fx16awyzWc3uol4w1g2T9O5cdUlRokB0g03vT/YbQfGmaZj"

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :payfy, Payfy.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
