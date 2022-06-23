defmodule Mintacoin.AssetFactory do
  @moduledoc """
  Allow the creation of assets while testing.
  """

  alias Mintacoin.{Asset, Blockchain, Minter}
  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      @spec asset_factory(attrs :: map()) :: Asset.t()
      def asset_factory(attrs) do
        %Blockchain{id: blockchain_id} = Map.get(attrs, :blockchain, insert(:blockchain))

        %Minter{id: minter_id, email: email, name: name} =
          Map.get(attrs, :minter, insert(:minter))

        code = Map.get(attrs, :code, "MTK:#{minter_id}")
        supply = Map.get(attrs, :supply, "10000")

        evaluate_lazy_attributes(%Asset{
          id: UUID.generate(),
          blockchain_id: blockchain_id,
          minter_id: minter_id,
          code: code,
          supply: supply
        })
      end
    end
  end
end
