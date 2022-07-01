defmodule Mintacoin.Crypto.PaymentCreated do
  @moduledoc """
  `PaymentCreated` struct definition
  """

  @type asset_code :: String.t()
  @type asset_issuer :: String.t()
  @type asset :: [code: asset_code(), issuer: asset_issuer()] | :native

  @type t :: %__MODULE__{
          source_secret: String.t(),
          destination_secret: String.t(),
          asset: asset(),
          amount: number(),
          successful: boolean(),
          tx_json: map()
        }

  defstruct [
    :source_secret,
    :destination_secret,
    :asset,
    :amount,
    :successful,
    :tx_json
  ]
end
