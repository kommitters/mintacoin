defmodule Mintacoin.Asset do
  @moduledoc """
  Ecto schema for Asset
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Mintacoin.{Blockchain, Minter}

  @type t :: %__MODULE__{
          code: String.t(),
          supply: String.t(),
          minter: Minter.t(),
          blockchain: Blockchain.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "assets" do
    field(:code, :string)
    field(:supply, :string)
    belongs_to(:minter, Minter, type: :binary_id)
    belongs_to(:blockchain, Blockchain, type: :binary_id)

    timestamps()
  end

  @spec changeset(asset :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def changeset(asset, changes) do
    asset
    |> cast(changes, [:code, :supply, :minter_id, :blockchain_id])
    |> validate_required([:code, :supply, :minter_id, :blockchain_id])
    |> validate_format(:supply, ~r/^\d+$/, message: "must have number format")
    |> unique_constraint([:code])
    |> foreign_key_constraint(:minter_id)
    |> foreign_key_constraint(:blockchain_id)
  end
end
