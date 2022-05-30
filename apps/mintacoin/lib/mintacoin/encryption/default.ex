defmodule Mintacoin.Encryption.Default do
  @moduledoc """
  This module provides a default implementation o for the Encryption
  module using :crypto erlang's module.
  """

  @behaviour Mintacoin.Encryption.Spec

  @block_size 16
  @cipher :aes_128_cbc
  @hash_algorithm :sha256

  @impl true
  def generate_secret do
    @block_size
    |> :crypto.strong_rand_bytes()
    |> Base.encode64(padding: false)
  end

  @impl true
  def one_time_token do
    @block_size
    |> :crypto.strong_rand_bytes()
    |> (&:crypto.hash(@hash_algorithm, &1)).()
    |> Base.encode64(padding: false)
    |> (&{:ok, &1}).()
  end

  @impl true
  def encrypt(payload, key) do
    {:ok, secret_key} = Base.decode64(key, padding: false)
    iv = :crypto.strong_rand_bytes(@block_size)
    plaintext = pad(payload, @block_size)

    ciphertext =
      @cipher
      |> :crypto.crypto_one_time(secret_key, iv, plaintext, true)
      |> (&(iv <> &1)).()
      |> Base.encode64(padding: false)

    {:ok, ciphertext}
  rescue
    :error -> {:error, :decoding_error}
    _error -> {:error, :encryption_error}
  end

  @impl true
  def decrypt(ciphertext, key) do
    with {:ok, secret_key} <- Base.decode64(key, padding: false),
         {:ok, <<iv::binary-16, ciphertext::binary>>} <- Base.decode64(ciphertext, padding: false) do
      plaintext =
        @cipher
        |> :crypto.crypto_one_time(secret_key, iv, ciphertext, false)
        |> unpad()

      {:ok, plaintext}
    else
      _error -> {:error, :decoding_error}
    end
  end

  @spec unpad(data :: String.t()) :: String.t()
  defp unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  @spec pad(data :: String.t(), block_size :: integer()) :: String.t()
  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_add>>, to_add)
  end
end
