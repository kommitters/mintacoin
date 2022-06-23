defmodule Mintacoin.Payment do
  @moduledoc """
  Ecto schema for Payment
  """

  use Ecto.Schema

  import Ecto.Changeset
  import EctoEnum

  alias Ecto.Changeset
  alias Mintacoin.{Account, Asset}

  @type status :: :emitted | :processed

  @type t :: %__MODULE__{
          source_account: Account.t(),
          destination_account: Account.t(),
          asset: Asset.t(),
          amount: String.t(),
          status: status()
        }

  @uuid_regex ~r/^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/

  defenum(Status, :status, [:emitted, :processed])

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "payments" do
    belongs_to(:source_account, Account,
      foreign_key: :source,
      references: :address,
      type: :binary_id
    )

    belongs_to(:destination_account, Account,
      foreign_key: :destination,
      references: :address,
      type: :binary_id
    )

    belongs_to(:asset, Asset, foreign_key: :asset_code, references: :code, type: :string)

    field(:amount, :string)
    field(:status, Status, default: :emitted)

    timestamps()
  end

  @spec create_changeset(payment :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def create_changeset(payment, changes) do
    payment
    |> cast(changes, [:source, :destination, :asset_code, :amount, :status])
    |> validate_required([
      :source,
      :destination,
      :asset_code,
      :amount
    ])
    |> validate_format(:source, @uuid_regex, message: "source must be an uuid")
    |> validate_format(:destination, @uuid_regex, message: "destination must be an uuid")
    |> foreign_key_constraint(:source)
    |> foreign_key_constraint(:destination)
    |> foreign_key_constraint(:asset_code)
    |> validate_format(:amount, ~r/^\d+(\.\d+)?$/, message: "must have a decimal number format")
  end

  @spec changeset(payment :: t(), changes :: map()) :: Changeset.t()
  def changeset(payment, changes) do
    payment
    |> cast(changes, [:status])
    |> validate_required([:status])
  end
end
