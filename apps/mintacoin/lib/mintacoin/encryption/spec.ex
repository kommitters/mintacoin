defmodule Mintacoin.Encryption.Spec do
  @moduledoc """
  Specifies the functions available for the Encryption
  """

  @type secret() :: String.t()
  @type ciphertext() :: String.t()
  @type payload() :: String.t()
  @type public_key() :: String.t()
  @type secret_key() :: String.t()
  @type token() :: String.t()
  @type encrypted_secret() :: String.t()
  @type seed_words() :: list(String.t())
  @type keypair() :: {public_key(), secret_key()}
  @type error() :: {:error, :decoding_error | :encryption_error}

  @callback generate_secret :: secret()

  @callback encrypt(payload(), secret()) :: {:ok, ciphertext()} | error()

  @callback decrypt(ciphertext(), secret()) :: {:ok, payload()} | error()

  @callback random_keypair() :: {:ok, keypair()}

  @callback pk_from_sk(secret_key()) :: {:ok, keypair()} | error()

  @callback one_time_token() :: {:ok, token()}

  @callback seed_words_from_sk(secret_key()) ::
              {:ok, {encrypted_secret(), seed_words()}} | error()

  @callback sk_from_seed_words(encrypted_secret(), seed_words()) ::
              {:ok, encrypted_secret()} | error()
end
