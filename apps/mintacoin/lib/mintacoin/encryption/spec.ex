defmodule Mintacoin.Encryption.Spec do
  @moduledoc """
  Specifies the functions available for the Encryption
  """

  @type secret() :: String.t()
  @type ciphertext() :: String.t()
  @type payload() :: String.t()
  @type token() :: String.t()
  @type error() :: :decoding_error | :encryption_error

  @callback generate_secret :: secret()

  @callback encrypt(payload(), secret()) :: {:ok, ciphertext()} | {:error, error()}

  @callback decrypt(ciphertext(), secret()) :: {:ok, payload()} | {:error, error()}

  @callback one_time_token() :: {:ok, token()}
end
