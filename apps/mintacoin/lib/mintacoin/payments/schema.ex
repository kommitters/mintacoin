defmodule Mintacoin.Payment do
  @moduledoc """
  Ecto schema for Payment
  """

  use Ecto.Schema

  import Ecto.Changeset
  import EctoEnum

  alias Ecto.Changeset
  alias Mintacoin.{Account, Blockchain, Asset}

  @type status :: :emitted | :processed

  @type t :: %__MODULE__{
          source: Account.t(),
          destination: Account.t(),
          blockchain: Blockchain.t(),
          asset: Asset.t(),
          amount: String.t(),
          status: status()
        }

  defenum(Status, :status, [:emitted, :processed])

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "payments" do
    belongs_to(:source, Account, type: :binary_id)
    belongs_to(:destination, Account, type: :binary_id)
    belongs_to(:blockchain, Blockchain, type: :binary_id)
    belongs_to(:asset, Asset, type: :binary_id)
    field(:amount, :string)
    field(:status, Status, default: :emitted)

    timestamps()
  end

  @spec changeset(asset :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def changeset(asset, changes) do
    asset
    |> cast(changes, [:source_id, :destination_id, :blockchain_id, :asset_id, :amount, :status])
    |> validate_required([
      :source_id,
      :destination_id,
      :blockchain_id,
      :asset_id,
      :amount
    ])
    |> foreign_key_constraint(:source_id)
    |> foreign_key_constraint(:destination_id)
    |> foreign_key_constraint(:blockchain_id)
    |> foreign_key_constraint(:asset_id)
  end
end
