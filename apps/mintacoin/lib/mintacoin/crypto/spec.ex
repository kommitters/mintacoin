defmodule Mintacoin.Crypto.Spec do
  @moduledoc """
  Defines contracts for the transactions available in the Crypto layer.
  """

  @type status :: :ok | :error

  @callback create_account(map()) :: {status(), struct()}

  @callback create_asset(map()) :: {status(), struct()}

  @callback authorize_asset(map()) :: {status(), struct()}

  @callback process_payment(map()) :: {status(), struct()}
end
