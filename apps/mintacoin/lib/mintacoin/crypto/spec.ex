defmodule Mintacoin.Crypto.Spec do
  @moduledoc """
  Defines contracts for the transactions available in the Crypto layer.
  """

  @callback create_account(map()) :: {:ok | :error, struct()}

  @callback create_asset(map()) :: {:ok | :error, struct()}

  @callback authorize_asset(map()) :: {:ok | :error, struct()}

  @callback process_payment(map()) :: {:ok | :error, struct()}
end
