defmodule Mintacoin.Encryption.Spec do
  @moduledoc """
  Specifies the functions available for the Encryption
  """

  @type secret() :: String.t()
  @type ciphertext() :: String.t()
  @type payload() :: String.t()
  @type public_key() :: String.t()
  @type secret_key() :: String.t()
  @type token_encoded() :: String.t()
  @type token_hashed() :: String.t()
  @type encrypted_secret() :: String.t()
  @type seed_words() :: list()
  @type keypair() :: {public_key(), secret_key()}
  @type token_pair() :: {token_encoded(), token_hashed()}
  @type decoding_error() :: {:error, :decode_64_error}
  @type decryption_error() :: {:error, :error_in_decryption | :decode_64_error}
  @type encryption_error() :: {:error, :error_in_encryption | :decode_64_error}

  @callback generate_secret :: secret()

  @callback encrypt(payload(), secret()) :: {:ok, ciphertext()} | encryption_error()

  @callback decrypt(ciphertext(), secret()) :: {:ok, payload()} | decryption_error()

  @callback random_keypair() :: {:ok, keypair()}

  @callback pk_from_sk(secret_key()) :: {:ok, keypair()} | decoding_error()

  @callback one_time_token() :: {:ok, token_pair()}

  @callback seed_words_from_sk(secret_key()) ::
              {:ok, {encrypted_secret(), seed_words()}} | encryption_error()

  @callback sk_from_seed_words(encrypted_secret(), seed_words()) ::
              {:ok, encrypted_secret()} | decryption_error()
end
