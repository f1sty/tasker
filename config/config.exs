# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tasker,
  ecto_repos: [Tasker.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :tasker, TaskerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dwDOHUEdr1icy4DRUVZFLEIRFGG3bgqn65KoiXOIGvRH/dYdSSCkO0fX3mSpt4FQ",
  render_errors: [view: TaskerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Tasker.PubSub,
  live_view: [signing_salt: "5ZCalc42"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
