defmodule Mintacoin.Events.Listener do
  @moduledoc """
  This module is responsible for listening the events created through the BlockchainEvents table.

   - The database notifier event is `event_created`
  """

  use GenServer

  alias Mintacoin.{Events.Structs.AccountCreated, BlockchainEvent}

  @spec child_spec(opts :: Keyword.t()) :: map()
  def child_spec(opts) do
    %{
      id: Keyword.get(opts, :id, __MODULE__),
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, opts)

  @impl true
  def init(opts) do
    case Mintacoin.Repo.listen("event_created") do
      {:ok, _pid, _ref} -> {:ok, opts}
      error -> {:stop, error}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "event_created", payload}, _state) do
    with {:ok, %{record: record}} <- Jason.decode(payload, keys: :atoms),
         %BlockchainEvent{} = blockchain_event <- struct!(BlockchainEvent, record) do
      payload = cast_payload(blockchain_event)

      {:noreply, payload}
    else
      error -> {:stop, error, []}
    end
  end

  defp cast_payload(%{event_type: "create_account", event_payload: event_payload}),
    do: struct(AccountCreated, event_payload)
end
