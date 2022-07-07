defmodule Mintacoin.Wallet do
  @moduledoc """
  Ecto schema for Wallet
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Mintacoin.{Account, Blockchain, BlockchainEvent}

  @type t :: %__MODULE__{
          address: String.t(),
          encrypted_secret: String.t(),
          settled_in_blockchain: boolean(),
          account: Account.t(),
          blockchain: Blockchain.t(),
          blockchain_event: BlockchainEvent.t()
        }

  @uuid_regex ~r/^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "wallets" do
    field(:address, :string)
    field(:encrypted_secret, :string)
    field(:settled_in_blockchain, :boolean, default: false)
    belongs_to(:account, Account, type: :binary_id)
    belongs_to(:blockchain, Blockchain, type: :binary_id)
    belongs_to(:blockchain_event, BlockchainEvent, type: :binary_id)

    field(:secret, :string, virtual: true)

    timestamps()
  end

  @spec create_changeset(wallet :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def create_changeset(wallet, changes) do
    wallet
    |> cast(changes, [
      :address,
      :encrypted_secret,
      :settled_in_blockchain,
      :account_id,
      :blockchain_id,
      :blockchain_event_id,
      :secret
    ])
    |> validate_required([:address, :encrypted_secret, :account_id, :blockchain_id])
    |> validate_format(:account_id, @uuid_regex, message: "account_id must be a uuid")
    |> validate_format(:blockchain_id, @uuid_regex, message: "blockchain_id must be a uuid")
    |> validate_format(:blockchain_event_id, @uuid_regex,
      message: "blockchain_event_id must be a uuid"
    )
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:blockchain_id)
    |> foreign_key_constraint(:blockchain_event_id)
    |> unique_constraint([:account_id, :blockchain_id], name: :account_blockchain_index)
  end

  @spec changeset(wallet :: t(), changes :: map()) :: Changeset.t()
  def changeset(wallet, changes) do
    wallet
    |> cast(changes, [:settled_in_blockchain, :blockchain_event_id])
    |> validate_format(:blockchain_event_id, @uuid_regex,
      message: "blockchain_event_id must be a uuid"
    )
    |> foreign_key_constraint(:blockchain_event_id)
  end
end
