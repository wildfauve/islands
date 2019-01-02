defmodule Islands.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ets.new(:game_state, [:public, :named_table])
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Registry.Game},
      Islands.GameSupervisor
      # Starts a worker by calling: Islands.Worker.start_link(arg)
      # {Islands.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Islands.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
