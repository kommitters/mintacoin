defmodule Mintacoin.Crypto.AccountCreated do
  @moduledoc """
  `AccountCreated` struct definition
  """

  @type t :: %__MODULE__{
          minter_wallet_secret: String.t(),
          account_wallet_address: String.t(),
          account_wallet_secret: String.t(),
          initial_balance: float(),
          successful: boolean(),
          tx_json: map()
        }

  defstruct [
    :minter_wallet_secret,
    :account_wallet_address,
    :account_wallet_secret,
    :initial_balance,
    :successful,
    :tx_json
  ]
end
