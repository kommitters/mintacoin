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
  def pk_from_sk(secret_key), do: impl().pk_from_sk(secret_key)

  @impl true
  def one_time_token, do: impl().one_time_token()

  @impl true
  def seed_words_from_sk(secret_key), do: impl().seed_words_from_sk(secret_key)

  @impl true
  def sk_from_seed_words(encrypted_secret, seed_words),
    do: impl().sk_from_seed_words(encrypted_secret, seed_words)

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:encryption, :impl, Default)
end
