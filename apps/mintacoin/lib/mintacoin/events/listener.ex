defmodule Mintacoin.Events.Listener do
  @moduledoc """
  This module is responsible for listening the events created through the BlockchainEvents table.

   - The database notifier event is `event_created`
  """

  use GenServer

  alias Ecto.Changeset
  alias Mintacoin.{BlockchainEvent, Events.Consumer}

  @type error ::
          Changeset.t()
          | :bad_blockchain_event_provided
          | :blockchain_transaction_error
          | :blockchain_transaction_failed
          | :invalid_event_payload
          | :bad_argument
          | :not_found

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
    with {:ok, %{record: %{event_type: event_type} = record}} <-
           Jason.decode(payload, keys: :atoms),
         %BlockchainEvent{} = blockchain_event <-
           struct(BlockchainEvent, %{record | event_type: String.to_existing_atom(event_type)}) do
      blockchain_event
      |> submit_blockchain_transaction()
      |> (&{:noreply, &1}).()
    else
      error -> {:stop, error, []}
    end
  end

  @spec submit_blockchain_transaction(blockchain_event :: BlockchainEvent.t()) ::
          {:ok, BlockchainEvent.t()} | {:error, error()}
  defp submit_blockchain_transaction(
         %BlockchainEvent{event_type: :create_account} = blockchain_event
       ),
       do: Consumer.create_account(blockchain_event)

  defp submit_blockchain_transaction(_blockchain_event) do
    {:error, :bad_blockchain_event_provided}
  end
end
