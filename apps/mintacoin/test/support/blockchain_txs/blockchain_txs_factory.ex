defmodule Mintacoin.BlockchainTxFactory do
  @moduledoc """
  Allow the creation of BlockchainTxs while testing.
  """

  alias Ecto.UUID
  alias Mintacoin.{BlockchainTx, Blockchain}

  defmacro __using__(_opts) do
    quote do
      @spec blockchain_tx_factory(attrs :: map()) :: BlockchainTx.t()
      def blockchain_tx_factory(attrs) do
        operation_type = Map.get(attrs, :operation_type, :create_account)
        operation_payload = Map.get(attrs, :operation_payload, %{})
        signatures = Map.get(attrs, :signatures, [])
        state = Map.get(attrs, :state, :pending)
        successful = Map.get(attrs, :successful, false)
        tx_id = Map.get(attrs, :tx_id, nil)
        tx_hash = Map.get(attrs, :tx_hash, nil)
        tx_response = Map.get(attrs, :tx_response, %{})
        %Blockchain{id: blockchain_id} = Map.get(attrs, :blockchain, insert(:blockchain))

        %BlockchainTx{
          id: UUID.generate(),
          operation_type: operation_type,
          operation_payload: operation_payload,
          signatures: signatures,
          successful: successful,
          tx_id: tx_id,
          tx_hash: tx_hash,
          tx_response: tx_response,
          blockchain_id: blockchain_id
        }
      end
    end
  end
end
