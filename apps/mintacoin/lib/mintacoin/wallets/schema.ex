defmodule Mintacoin.Wallet do
  @moduledoc """
  Ecto schema for Wallet
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Mintacoin.{Account, Blockchain}

  @type t :: %__MODULE__{
          address: String.t(),
          encrypted_secret: String.t(),
          account: Account.t(),
          blockchain: Blockchain.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "wallets" do
    field(:address, :string)
    field(:encrypted_secret, :string)
    belongs_to(:account, Account, type: :binary_id)
    belongs_to(:blockchain, Blockchain, type: :binary_id)

    timestamps()
  end

  @spec changeset(wallet :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def changeset(wallet, changes) do
    wallet
    |> cast(changes, [:address, :encrypted_secret, :account_id, :blockchain_id])
    |> validate_required([:address, :encrypted_secret, :account_id, :blockchain_id])
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:blockchain_id)
    |> unique_constraint([:account_id, :blockchain_id], name: :account_blockchain_index)
  end
end
