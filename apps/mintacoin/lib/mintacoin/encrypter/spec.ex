defmodule Mintacoin.Encrypter.Spec do
  @moduledoc """
  Specifies the functions available for the Encrypter
  """

  @type secret() :: String.t()
  @type ciphertext() :: String.t()
  @type public_key() :: String.t()
  @type payload() :: String.t()
  @type key() :: String.t()
  @type secret_key() :: String.t()
  @type token_encoded() :: String.t()
  @type token_hashed() :: String.t()
  @type encrypted_secret() :: String.t()
  @type seed_words() :: list()
  @type keypair() :: {public_key(), secret_key()}
  @type token_pair() :: {token_encoded(), token_hashed()}

  # DEFINIR ERRORES

  @callback generate_secret :: secret()

  @callback encrypt(payload(), key()) :: {:ok, ciphertext()}

  @callback decrypt(ciphertext(), key()) :: {:ok, payload()}

  @callback random_keypair() :: {:ok, keypair()}

  @callback pk_from_sk(secret_key()) :: {:ok, keypair()}

  @callback one_time_token() :: {:ok, token_pair()}

  @callback seed_words_from_sk(secret_key()) :: {:ok, {encrypted_secret(), seed_words()}}

  @callback sk_from_seed_words(encrypted_secret(), seed_words()) :: {:ok, encrypted_secret()}
end
