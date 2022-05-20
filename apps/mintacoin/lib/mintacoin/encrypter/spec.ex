defmodule Mintacoin.Encrypter.Spec do
  @moduledoc """
  Specifies the functions available for the Encrypter
  """

  @callback generate_secret :: binary()

  @callback encrypt(val :: String.t(), key :: String.t()) :: String.t()

  @callback decrypt(ciphertext :: String.t(), key :: String.t()) :: String.t()
end
