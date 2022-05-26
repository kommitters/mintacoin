defmodule Mintacoin.Encryption do
  @moduledoc """
  This module provides the boundary for the Encryption's operations.
  """

  @behaviour Mintacoin.Encryption.Spec

  alias Mintacoin.Encryption.Default

  @impl true
  def generate_secret, do: impl().generate_secret()

  @impl true
  def encrypt(payload, key), do: impl().encrypt(payload, key)

  @impl true
  def decrypt(ciphertext, key), do: impl().decrypt(ciphertext, key)

  @impl true
  def random_keypair, do: impl().random_keypair()

  @impl true
  def public_key_from_secret_key(secret_key), do: impl().public_key_from_secret_key(secret_key)

  @impl true
  def one_time_token, do: impl().one_time_token()

  @impl true
  def mnemonic_encrypt(secret_key), do: impl().mnemonic_encrypt(secret_key)

  @impl true
  def recover_secret_key_from_seed_words(encrypted_secret, seed_words),
    do: impl().recover_secret_key_from_seed_words(encrypted_secret, seed_words)

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:encryption, :impl, Default)
end
