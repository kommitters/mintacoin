defmodule Mintacoin.Keypair.Spec do
  @moduledoc """
  Specifies the functions available for the Keypair module
  """

  @type public_key() :: String.t()
  @type secret_key() :: String.t()
  @type keypair() :: {public_key(), secret_key()}
  @type error() :: :secret_key_error

  @callback random() :: {:ok, keypair()}

  @callback from_secret_key(secret_key()) :: {:ok, keypair()} | {:error, error()}
end
