defmodule Mintacoin.AccountFactory do
  @moduledoc """
  Allow the creation of accounts while testing.
  """

  alias Mintacoin.Account
  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      @spec account_factory(attrs :: map()) :: Account.t()
      def account_factory(attrs) do
        email = Map.get(attrs, :email, sequence(:email, &"account#{&1}@example.com"))
        name = Map.get(attrs, :name, sequence(:name, &"Account #{&1}"))
        address = Map.get(attrs, :address, UUID.generate())
        derived_key = Map.get(attrs, :derived_key, sequence(:derived_key, &"derived_key#{&1}"))

        encrypted_signature =
          Map.get(
            attrs,
            :encrypted_signature,
            sequence(:encrypted_signature, &"encrypted_signature#{&1}")
          )

        signature =
          Map.get(
            attrs,
            :signature,
            sequence(:signature, &"signature#{&1}")
          )

        seed_words =
          Map.get(
            attrs,
            :seed_words,
            sequence(:seed_words, &"word#{&1} ")
            |> String.duplicate(12)
            |> String.trim_trailing()
          )

        status = Map.get(attrs, :status, :active)

        %Account{
          id: UUID.generate(),
          email: email,
          name: name,
          address: address,
          derived_key: derived_key,
          encrypted_signature: encrypted_signature,
          status: status,
          signature: signature,
          seed_words: seed_words
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
