defmodule Aisf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Aisf.PubSub},
      # Start the Ecto repository
      Aisf.Repo,
      # Start the endpoint when the application starts
      AisfWeb.Endpoint
      # Starts a worker by calling: Aisf.Worker.start_link(arg)
      # {Aisf.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aisf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AisfWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
