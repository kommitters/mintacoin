defmodule Mintacoin.PaymentFactory do
  @moduledoc """
  Allow the creation of payments while testing.
  """

  alias Mintacoin.{Payment, Account, Asset}
  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      @spec payment_factory(attrs :: map()) :: Payment.t()
      def payment_factory(attrs) do
        %Account{address: source_address} = Map.get(attrs, :source, insert(:account))
        %Account{address: destination_address} = Map.get(attrs, :destination, insert(:account))
        %Asset{code: code} = Map.get(attrs, :asset, insert(:asset))
        status = Map.get(attrs, :status, :emitted)

        %Payment{
          id: UUID.generate(),
          source: source_address,
          destination: destination_address,
          asset_code: code,
          amount: "10000",
          status: status
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
