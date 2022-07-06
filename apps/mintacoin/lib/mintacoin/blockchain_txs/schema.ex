defmodule Mintacoin.BlockchainTx do
  @moduledoc """
  Ecto schema for BlockchainTx
  """

  use Ecto.Schema

  import Ecto.Changeset
  import EctoEnum

  alias Ecto.Changeset
  alias Mintacoin.Blockchain

  @type operation_type :: :create_account | :mint_asset | :authorize_asset | :payment | :signature
  @type state :: :pending | :processing | :completed

  @type t :: %__MODULE__{
          operation_type: operation_type(),
          operation_payload: map(),
          signatures: list(String.t()),
          state: state(),
          successful: boolean(),
          tx_id: String.t(),
          tx_hash: String.t(),
          tx_response: map(),
          blockchain: Blockchain.t()
        }

  defenum(OperationType, :operation_type, [
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
  schema "blockchain_txs" do
    belongs_to(:blockchain, Blockchain, type: :binary_id)
    field(:operation_type, OperationType)
    field(:operation_payload, :map)
    field(:signatures, {:array, :string})
    field(:state, State, default: :pending)
    field(:successful, :boolean, default: false)
    field(:tx_id, :string)
    field(:tx_hash, :string)
    field(:tx_response, :map, default: %{})

    timestamps()
  end

  @spec changeset(blockchain_tx :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def changeset(blockchain_tx, changes),
    do:
      cast(blockchain_tx, changes, [
        :signatures,
        :state,
        :successful,
        :tx_id,
        :tx_hash,
        :tx_response
      ])

  @spec create_changeset(blockchain_tx :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def create_changeset(blockchain_tx, changes) do
    blockchain_tx
    |> cast(changes, [
      :blockchain_id,
      :operation_type,
      :operation_payload,
      :signatures,
      :state,
      :successful,
      :tx_id,
      :tx_hash,
      :tx_response
    ])
    |> validate_required([:blockchain_id, :operation_type, :operation_payload, :signatures])
    |> foreign_key_constraint(:blockchain_id)
  end
end
