defmodule Mintacoin.BlockchainEvent do
  @moduledoc """
  Ecto schema for BlockchainEvent
  """

  use Ecto.Schema

  import Ecto.Changeset
  import EctoEnum

  alias Ecto.Changeset
  alias Mintacoin.Blockchain

  @type event_type :: :create_account | :mint_asset | :authorize_asset | :payment | :signature
  @type state :: :pending | :processing | :completed

  @type t :: %__MODULE__{
          event_type: event_type(),
          event_payload: map(),
          state: state(),
          successful: boolean(),
          tx_id: String.t(),
          tx_hash: String.t(),
          tx_response: map(),
          blockchain: Blockchain.t()
        }

  defenum(EventType, :event_type, [
    :create_account,
    :mint_asset,
    :authorize_asset,
    :payment,
    :signature
  ])

  defenum(State, :state, [
    :pending,
    :processing,
    :completed
  ])

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "blockchain_events" do
    belongs_to(:blockchain, Blockchain, type: :binary_id)
    field(:event_type, EventType)
    field(:event_payload, :map)
    field(:state, State, default: :pending)
    field(:successful, :boolean, default: false)
    field(:tx_id, :string)
    field(:tx_hash, :string)
    field(:tx_response, :map, default: %{})

    timestamps()
  end

  @spec changeset(blockchain_event :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def changeset(blockchain_event, changes),
    do:
      cast(blockchain_event, changes, [
        :state,
        :successful,
        :tx_id,
        :tx_hash,
        :tx_response
      ])

  @spec create_changeset(blockchain_event :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def create_changeset(blockchain_event, changes) do
    blockchain_event
    |> cast(changes, [
      :blockchain_id,
      :event_type,
      :event_payload,
      :state,
      :successful,
      :tx_id,
      :tx_hash,
      :tx_response
    ])
    |> validate_required([:blockchain_id, :event_type, :event_payload])
    |> foreign_key_constraint(:blockchain_id)
  end
end
