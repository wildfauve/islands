defmodule Islands.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ets.new(:game_state, [:public, :named_table])
    children = [
      {Registry, keys: :unique, name: Registry.Game},
      Islands.GameSupervisor
    ]
    opts = [strategy: :one_for_one, name: Islands.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
