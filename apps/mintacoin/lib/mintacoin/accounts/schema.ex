defmodule Mintacoin.Account do
  @moduledoc """
  Ecto schema for Account
  """

  use Ecto.Schema

  import Ecto.Changeset
  import EctoEnum

  alias Ecto.Changeset

  @type payload :: String.t()
  @type token :: String.t()
  @type error :: :decoding_error | :encryption_error

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
    field(:is_active, :boolean, default: true)

    field(:secret_key, :string, virtual: true)
    field(:seed_words, :string, virtual: true)

    timestamps()
  end

  @spec changeset(account :: Account.t(), changes :: map()) :: Changeset.t()
  def changeset(account, changes) do
    account
    |> cast(changes, [
      :email,
      :name,
      :is_active
    ])
    |> unique_constraint([:email, :address, :encrypted_signature])
  end

  @spec create_changeset(account :: Account.t(), changes :: map()) :: Changeset.t()
  def create_changeset(account, changes) do
    account
    |> cast(changes, [
      :email,
      :name,
      :derived_key,
      :encrypted_signature,
      :is_active
    ])
    |> add_unique_address()
    |> encrypt_account_keypair()
    |> validate_required([:email, :name, :derived_key, :encrypted_signature])
    |> unique_constraint([:email])
    |> unique_constraint([:address])
    |> unique_constraint([:encrypted_signature])
  end

  @spec recover_secret_key(account :: Account.t(), seed_words :: String.t()) ::
          {:ok, payload()} | {:error, error()}
  def recover_secret_key(%{encrypted_signature: encrypted_signature}, seed_words) do
    {:ok, entropy} =
      seed_words
      |> String.split()
      |> Mintacoin.Mnemonic.to_entropy()

    Mintacoin.Encryption.decrypt(encrypted_signature, entropy)
  end

  def recover_secret_key(nil, _seed_words), do: {:error, :not_found}

  @spec add_unique_address(changeset :: Changeset.t()) :: Changeset.t()
  defp add_unique_address(changeset) do
    address = Ecto.UUID.generate()

    cast(changeset, %{address: address}, [:address])
  end

  @spec encrypt_account_keypair(changeset :: Changeset.t()) :: Changeset.t()
  defp encrypt_account_keypair(changeset) do
    {:ok, {pk, sk}} = Mintacoin.Keypair.random()
    {:ok, {entropy, mnemonic}} = Mintacoin.Mnemonic.random_entropy_and_mnemonic()
    seed_words = Enum.join(mnemonic, " ")
    {:ok, encrypted_secret} = Mintacoin.Encryption.encrypt(sk, entropy)

    cast(
      changeset,
      %{
        derived_key: pk,
        encrypted_signature: encrypted_secret,
        seed_words: seed_words,
        secret_key: sk
      },
      [:derived_key, :encrypted_signature, :seed_words, :secret_key]
    )
  end
end
