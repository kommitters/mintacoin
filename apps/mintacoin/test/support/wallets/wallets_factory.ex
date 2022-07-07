defmodule Mintacoin.WalletFactory do
  @moduledoc """
  Allow the creation of Wallets while testing.
  """

  alias Ecto.UUID
  alias Mintacoin.{Wallet, Blockchain, Account, BlockchainEvent}

  defmacro __using__(_opts) do
    quote do
      @spec wallet_factory(attrs :: map()) :: Wallet.t()
      def wallet_factory(attrs) do
        address =
          Map.get(
            attrs,
            :address,
            sequence(:address, &"GAGWBYID5UOAZMX5GCSBDLJNTTI2OQXHI5SZANT2OSSQYO2MQ6BTW6OJ#{&1}")
          )

        encrypted_secret =
          Map.get(
            attrs,
            :encrypted_secret,
            sequence(
              :encrypted_secret,
              &"cnRBGzF4bKR4GMby657ur6Seu2oyKFvQv3U/rp+3uoCzIgKyRpaQqMqx8zUvI1ESeGrlxTfswSGaX0Kr9g3+4lCtmA0jTtzXpykrJyZZ6QA#{&1}"
            )
          )

        settled_in_blockchain = Map.get(attrs, :settled_in_blockchain, false)
        %Account{id: account_id} = Map.get(attrs, :account, insert(:account))
        %Blockchain{id: blockchain_id} = Map.get(attrs, :blockchain, insert(:blockchain))

        blockchain_event_id =
          case Map.get(attrs, :blockchain_event) do
            %BlockchainEvent{id: blockchain_event_id} -> blockchain_event_id
            nil -> nil
          end

        evaluate_lazy_attributes(%Wallet{
          id: UUID.generate(),
          address: address,
          encrypted_secret: encrypted_secret,
          settled_in_blockchain: settled_in_blockchain,
          account_id: account_id,
          blockchain_id: blockchain_id,
          blockchain_event_id: blockchain_event_id
        })
      end
    end
  end
end
