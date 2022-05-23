defmodule Mintacoin.Encrypter.Default do
  @moduledoc false

  @behaviour Mintacoin.Encrypter.Spec

  @block_size 16

  @cipher :aes_128_cbc

  @impl true
  def generate_secret do
    @block_size
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  @impl true
  def encrypt(payload, key) do
    case Base.decode64(key) do
      {:ok, secret_key} ->
        iv = :crypto.strong_rand_bytes(@block_size)
        plaintext = pad(payload, @block_size)

        ciphertext =
          @cipher
          |> :crypto.crypto_one_time(secret_key, iv, plaintext, true)
          |> (&(iv <> &1)).()
          |> Base.encode64()

        {:ok, ciphertext}

      :error ->
        {:error, "Decode64 error"}
    end
  end

  @impl true
  def decrypt(ciphertext, key) do
    with {:ok, secret_key} <- Base.decode64(key),
         {:ok, <<iv::binary-16, ciphertext::binary>>} <- Base.decode64(ciphertext) do
      plaintext =
        @cipher
        |> :crypto.crypto_one_time(secret_key, iv, ciphertext, false)
        |> unpad()

      {:ok, plaintext}
    else
      :error -> {:error, "Decode64 error"}
      _ -> {:error, "Pattern matching error"}
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
