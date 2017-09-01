# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :combatless,
  ecto_repos: [Combatless.Repo]

# Configures the endpoint
config :combatless, CombatlessWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gHlKFUTqsReIFu3BWWiGK68i/a+taoE3wAjelY+t4O8K02oHWXRSATqfQ973H9jB",
  render_errors: [view: CombatlessWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Combatless.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
