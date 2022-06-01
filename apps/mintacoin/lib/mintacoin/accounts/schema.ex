defmodule Mintacoin.Account do
  @moduledoc """
  Ecto schema for Account
  """

  use Ecto.Schema

  import Ecto.Changeset
  import EctoEnum

  alias Ecto.Changeset
  alias Ecto.UUID

  @type status :: :active | :archived

  @type t :: %__MODULE__{
          email: String.t(),
          name: String.t(),
          address: UUID.t(),
          derived_key: String.t(),
          encrypted_signature: String.t(),
          status: status()
        }

  defenum(Status, :status, [
    :active,
    :archived
  ])

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "accounts" do
    field(:email, :string)
    field(:name, :string)
    field(:address, :binary_id)
    field(:derived_key, :string)
    field(:encrypted_signature, :string)
    field(:status, Status, default: :active)

    field(:signature, :string, virtual: true)
    field(:seed_words, :string, virtual: true)

    timestamps()
  end

  @spec changeset(account :: Account.t(), changes :: map()) :: Changeset.t()
  def changeset(account, changes) do
    account
    |> cast(changes, [
      :email,
      :name,
      :status
    ])
    |> unique_constraint([:email])
  end

  @spec create_changeset(account :: Account.t(), changes :: map()) :: Changeset.t()
  def create_changeset(account, changes) do
    account
    |> cast(changes, [
      :email,
      :name,
      :derived_key,
      :encrypted_signature,
      :status,
      :seed_words,
      :signature
    ])
    |> add_unique_address()
    |> validate_required([:email, :name, :derived_key, :encrypted_signature])
    |> unique_constraint([:email])
    |> unique_constraint([:address])
    |> unique_constraint([:encrypted_signature])
  end

  @spec add_unique_address(changeset :: Changeset.t()) :: Changeset.t()
  defp add_unique_address(changeset) do
    UUID.generate()
    |> (&put_change(changeset, :address, &1)).()
  end
end
