defmodule Mintacoin.Encrypter do
  @moduledoc """
  This module provides the boundary for the Encrypter's operations.
  """

  @behaviour Mintacoin.Encrypter.Spec

  @impl true
  def generate_secret, do: impl().generate_secret()

  @impl true
  def encrypt(payload, key), do: impl().encrypt(payload, key)

  @impl true
  def decrypt(ciphertext, key), do: impl().decrypt(ciphertext, key)

  @impl true
  def random(), do: impl().random()

  @impl true
  def from_secret(secret_key), do: impl().from_secret(secret_key)

  @impl true
  def one_time_token(), do: impl().one_time_token()

  @impl true
  def encrypt_with_seed_words(secret_key), do: impl().encrypt_with_seed_words(secret_key)

  @impl true
  def decrypt_with_seed_words(encrypted_secret, seed_words),
    do: impl().decrypt_with_seed_words(encrypted_secret, seed_words)

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:encrypter, :impl, Mintacoin.Encrypter.Default)
end
