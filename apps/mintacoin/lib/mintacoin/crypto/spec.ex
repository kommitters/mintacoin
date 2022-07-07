defmodule Mintacoin.Crypto.Spec do
  @moduledoc """
  Defines contracts for the transactions available in the Crypto layer.
  """

  alias Mintacoin.Crypto.TxResponse

  @type status :: :ok | :error
  @type public_key :: String.t()
  @type secret_key :: String.t()
  @type keypair :: {public_key(), secret_key()}

  @callback random_keypair() :: keypair()

  @callback create_account(map()) :: {status(), TxResponse.t()}

  @callback create_asset(map()) :: {status(), TxResponse.t()}

  @callback authorize_asset(map()) :: {status(), TxResponse.t()}

  @callback process_payment(map()) :: {status(), TxResponse.t()}
end
