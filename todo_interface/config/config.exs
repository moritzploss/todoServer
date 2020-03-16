# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :todo_interface,
  ecto_repos: [TodoInterface.Repo]

# Configures the endpoint
config :todo_interface, TodoInterfaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rGXSSqmMwvzppVz9xwgwAOCEYsuk8lYnjpshJ+u6k6SdR3hcxQ8nqoOEU+CLQvRG",
  render_errors: [view: TodoInterfaceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TodoInterface.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "w0ysyRRm"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
