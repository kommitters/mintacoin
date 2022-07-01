defmodule Mintacoin.Crypto.AssetAuthorized do
  @moduledoc """
  `AssetAuthorized` struct definition
  """

  @type t :: %__MODULE__{
          wallet_secret: String.t(),
          asset_code: String.t(),
          asset_issuer: String.t(),
          successful: boolean(),
          tx_json: map()
        }

  defstruct [
    :wallet_secret,
    :asset_code,
    :asset_issuer,
    :successful,
    :tx_json
  ]
end
