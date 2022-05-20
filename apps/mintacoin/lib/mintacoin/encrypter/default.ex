defmodule Mintacoin.Encrypter.Default do
  @moduledoc false

  @behaviour Mintacoin.Encrypter.Spec

  # @aad "AES256GCM"
  @block_size 16

  @spec unpad(data :: String.t()) :: String.t()
  def unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  # PKCS5Padding
  @spec pad(data :: String.t(), block_size :: integer()) :: String.t()
  def pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_add>>, to_add)
  end

  @impl true
  def generate_secret do
    :crypto.strong_rand_bytes(16)
    |> :base64.encode()
  end

  @impl true
  def encrypt(val, key) do
    mode = :aes_128_cbc
    secret_key = :base64.decode(key)
    iv = :crypto.strong_rand_bytes(16)
    plaintext = pad(val, @block_size)
    ciphertext = :crypto.crypto_one_time(mode, secret_key, iv, plaintext, true)

    (iv <> ciphertext)
    |> :base64.encode()
  end

  @impl true
  def decrypt(ciphertext, key) do
    mode = :aes_128_cbc
    secret_key = :base64.decode(key)
    ciphertext = :base64.decode(ciphertext)
    <<iv::binary-16, ciphertext::binary>> = ciphertext

    :crypto.crypto_one_time(mode, secret_key, iv, ciphertext, false)
    |> unpad()
  end
end
