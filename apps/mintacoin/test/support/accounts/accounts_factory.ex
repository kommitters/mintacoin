defmodule Mintacoin.AccountFactory do
  @moduledoc """
  Allow the creation of accounts while testing.
  """

  alias Mintacoin.{Account, Mnemonic, Encryption, Keypair}
  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      @spec account_factory(attrs :: map()) :: Account.t()
      def account_factory(attrs) do
        email = Map.get(attrs, :email, sequence(:email, &"account#{&1}@example.com"))
        name = Map.get(attrs, :name, sequence(:name, &"Account #{&1}"))
        address = Map.get(attrs, :address, UUID.generate())

        {:ok, {derived_key, signature}} = Keypair.random()

        account_signature = Map.get(attrs, :signature, signature)

        {:ok, {entropy, seed_words}} = Mnemonic.random_entropy_and_mnemonic()

        account_seed_words = Map.get(attrs, :seed_words, seed_words)

        {:ok, encrypted_signature} = Encryption.encrypt(signature, entropy)

        account_encrypted_signature = Map.get(attrs, :encrypted_signature, encrypted_signature)

        status = Map.get(attrs, :status, :active)

        %Account{
          id: UUID.generate(),
          email: email,
          name: name,
          address: address,
          derived_key: derived_key,
          encrypted_signature: account_encrypted_signature,
          status: status,
          signature: account_signature,
          seed_words: account_seed_words
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
