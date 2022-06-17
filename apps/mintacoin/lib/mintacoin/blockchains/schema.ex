defmodule Mintacoin.Blockchain do
  @moduledoc """
  Ecto schema for Blockchain
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Mintacoin.Wallet

  @type t :: %__MODULE__{name: String.t()}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "blockchains" do
    field(:name, :string)
    has_many(:wallets, Wallet)

    timestamps()
  end

  @spec changeset(blockchain :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def changeset(blockchain, changes) do
    blockchain
    |> cast(changes, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
