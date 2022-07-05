defmodule Mintacoin.BlockchainTxFactory do
  @moduledoc """
  Allow the creation of BlockchainTxs while testing.
  """

  alias Mintacoin.BlockchainTx

  defmacro __using__(_opts) do
    quote do
      @spec blockchain_tx_factory(attrs :: map()) :: BlockchainTx.t()
      def blockchain_tx_factory(attrs) do
        %BlockchainTx{}
      end
    end
  end
end
