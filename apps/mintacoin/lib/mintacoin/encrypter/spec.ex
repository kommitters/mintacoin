defmodule Mintacoin.Encrypter.Spec do
  @moduledoc """
  Specifies the functions available for the Encrypter
  """

  @callback generate_secret :: String.t()

  @callback encrypt(payload :: String.t(), key :: String.t()) :: {:ok | :error, String.t()}

  @callback decrypt(ciphertext :: String.t(), key :: String.t()) :: {:ok | :error, String.t()}
end
