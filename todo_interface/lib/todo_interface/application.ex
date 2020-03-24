defmodule TodoInterface.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # TodoInterface.Repo,
      TodoInterfaceWeb.Endpoint,
      TodoInterfaceWeb.Presence
    ]

    opts = [strategy: :one_for_one, name: TodoInterface.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TodoInterfaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
