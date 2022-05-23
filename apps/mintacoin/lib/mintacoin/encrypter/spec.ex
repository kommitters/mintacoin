defmodule Mintacoin.Encrypter.Spec do
  @moduledoc """
  Specifies the functions available for the Encrypter
  """

  @callback generate_secret :: String.t()

  @callback encrypt(payload :: String.t(), key :: String.t()) :: {:ok | :error, String.t()}

  @callback decrypt(ciphertext :: String.t(), key :: String.t()) :: {:ok | :error, String.t()}

  @callback random() :: {:ok, {String.t(), String.t()}}

  @callback from_secret(secret_key :: String.t()) :: {:ok, {String.t(), String.t()}}

  @callback one_time_token() :: {:ok, {String.t(), String.t()}}

  @callback encrypt_with_seed_words(secret_key_64 :: String.t()) :: {:ok, {String.t(), list()}}

  @callback decrypt_with_seed_words(encrypted_secret :: String.t(), seed_words :: list()) ::
              {:ok, String.t()}
end
