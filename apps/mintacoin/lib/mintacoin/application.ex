defmodule Mintacoin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Mintacoin.Repo,
      Mintacoin.Events.Listener,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mintacoin.PubSub}
      # Start a worker by calling: Mintacoin.Worker.start_link(arg)
      # {Mintacoin.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Mintacoin.Supervisor)
  end
end
