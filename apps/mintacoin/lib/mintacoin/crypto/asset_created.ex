defmodule Mintacoin.Crypto.AssetCreated do
  @moduledoc """
  `AssetCreated` struct definition
  """

  @type t :: %__MODULE__{
          issuer_secret: String.t(),
          distribution_secret: String.t(),
          asset_code: String.t(),
          asset_issuer: String.t(),
          asset_supply: number(),
          successful: boolean(),
          tx_json: map()
        }

  defstruct [
    :issuer_secret,
    :distribution_secret,
    :asset_code,
    :asset_issuer,
    :asset_supply,
    :successful,
    :tx_json
  ]
end
