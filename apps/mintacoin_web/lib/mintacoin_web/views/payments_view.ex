defmodule MintacoinWeb.PaymentsView do
  use MintacoinWeb, :view

  alias Mintacoin.Payment

  @spec render(template :: String.t(), assigns :: map()) :: map()
  def render("payment.json", %{
        payment: %Payment{
          source: source,
          destination: destination,
          asset_code: asset_code,
          amount: amount
        }
      }) do
    %{
      resource: "payment",
      source: source,
      destination: destination,
      amount: amount,
      asset_code: asset_code
    }
  end
end
