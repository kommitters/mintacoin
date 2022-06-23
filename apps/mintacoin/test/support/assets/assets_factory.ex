defmodule Mintacoin.AssetFactory do
  @moduledoc """
  Allow the creation of assets while testing.
  """

  alias Mintacoin.{Asset, Account, Blockchain, Minter}
  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      @spec asset_factory(attrs :: map()) :: Asset.t()
      def asset_factory(attrs) do
        %Blockchain{id: blockchain_id} = Map.get(attrs, :blockchain, insert(:blockchain))

        %Minter{id: minter_id, email: email, name: name} =
          Map.get(attrs, :minter, insert(:minter))

        %Account{address: address} =
          Map.get(attrs, :account, insert(:account, email: email, name: name))

        code = Map.get(attrs, :code, "MTK:#{address}")
        supply = Map.get(attrs, :supply, "10000")

        %Asset{
          id: UUID.generate(),
          blockchain_id: blockchain_id,
          minter_id: minter_id,
          code: code,
          supply: supply
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
