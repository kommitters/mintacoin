defmodule Mintacoin.BlockchainEventFactory do
  @moduledoc """
  Allow the creation of BlockchainEvents while testing.
  """

  alias Ecto.UUID
  alias Mintacoin.{BlockchainEvent, Blockchain}

  defmacro __using__(_opts) do
    quote do
      @spec blockchain_event_factory(attrs :: map()) :: BlockchainEvent.t()
      def blockchain_event_factory(attrs) do
        event_type = Map.get(attrs, :event_type, :create_account)

        event_payload =
          Map.get(attrs, :event_payload, %{
            "balance" => 1.5,
            "destination" => "GBROZ4DOLG3POUYZZ53Y6CEECNYM75VCY5ZSYSMOC25LMW4TMSKWL2SY"
          })

        state = Map.get(attrs, :state, :pending)
        successful = Map.get(attrs, :successful, false)
        tx_id = Map.get(attrs, :tx_id, nil)
        tx_hash = Map.get(attrs, :tx_hash, nil)
        tx_response = Map.get(attrs, :tx_response, %{})
        %Blockchain{id: blockchain_id} = Map.get(attrs, :blockchain, insert(:blockchain))

        evaluate_lazy_attributes(%BlockchainEvent{
          id: UUID.generate(),
          event_type: event_type,
          event_payload: event_payload,
          successful: successful,
          tx_id: tx_id,
          tx_hash: tx_hash,
          tx_response: tx_response,
          blockchain_id: blockchain_id
        })
      end
    end
  end
end
