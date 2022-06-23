defmodule Mintacoin.BlockchainFactory do
  @moduledoc """
  Allow the creation of assets while testing.
  """

  alias Mintacoin.{Blockchain, Blockchains.Network}
  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      @spec blockchain_factory(attrs :: map()) :: Blockchain.t()
      def blockchain_factory(attrs) do
        name = Map.get(attrs, :name, Network.name())

        %Blockchain{
          id: UUID.generate(),
          name: name
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
