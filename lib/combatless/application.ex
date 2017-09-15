defmodule Combatless.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Combatless.Repo, []),
      # Start the endpoint when the application starts
      supervisor(CombatlessWeb.Endpoint, []),
      # Start your own worker by calling: Combatless.Worker.start_link(arg1, arg2, arg3)
      # worker(Combatless.Worker, [arg1, arg2, arg3]),
      supervisor(ConCache, [[ttl_check: :timer.seconds(5), ttl: :timer.seconds(600)], [name: :site_users_ranks]])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Combatless.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CombatlessWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
