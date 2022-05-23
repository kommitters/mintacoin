defmodule Mintacoin.Encrypter.Default do
  @moduledoc false

  @behaviour Mintacoin.Encrypter.Spec

  @block_size 16
  @cipher :aes_128_cbc
  @language :english
  @hash_algorith :sha256

  @impl true
  def generate_secret do
    @block_size
    |> :crypto.strong_rand_bytes()
    |> Base.encode64(padding: false)
  end

  @impl true
  def one_time_token() do
    bytes_string = :crypto.strong_rand_bytes(@block_size)

    encoded_token = Base.encode64(bytes_string, padding: false)

    hashed_token =
      bytes_string
      |> (&:crypto.hash(@hash_algorith, &1)).()
      |> Base.encode64(padding: false)

    {:ok, {encoded_token, hashed_token}}
  end

  @impl true
  def encrypt(payload, key) do
    case Base.decode64(key, padding: false) do
      {:ok, secret_key} ->
        iv = :crypto.strong_rand_bytes(@block_size)
        plaintext = pad(payload, @block_size)

        ciphertext =
          @cipher
          |> :crypto.crypto_one_time(secret_key, iv, plaintext, true)
          |> (&(iv <> &1)).()
          |> Base.encode64(padding: false)

        {:ok, ciphertext}

      :error ->
        {:error, "Decode64 error"}
    end
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
      :error -> {:error, "Decode64 error"}
      _ -> {:error, "Pattern matching error"}
    end
  end

  @impl true
  def random() do
    :eddsa
    |> :crypto.generate_key(:ed25519)
    |> encoded64_keypair()
  end

  @impl true
  def from_secret(secret_key_64) do
    case Base.decode64(secret_key_64, padding: false) do
      {:ok, secret_key} ->
        :eddsa
        |> :crypto.generate_key(:ed25519, secret_key)
        |> encoded64_keypair()

      :error ->
        {:error, "Decode64 error"}
    end
  end

  @impl true
  def encrypt_with_seed_words(secret_key_64) do
    entropy = generate_secret()

    seed_words =
      entropy
      |> Base.decode64!(padding: false)
      |> Bip39.entropy_to_mnemonic(Bip39.get_words(@language))

    case encrypt(secret_key_64, entropy) do
      {:ok, encrypted_secret} ->
        {:ok, encrypted_secret, seed_words}

      error ->
        error
    end
  end

  @impl true
  def decrypt_with_seed_words(encrypted_secret, seed_words) do
    entropy =
      seed_words
      |> Bip39.mnemonic_to_entropy(Bip39.get_words(@language))
      |> Base.encode64(padding: false)

    case decrypt(encrypted_secret, entropy) do
      {:ok, secret_key_64} ->
        {:ok, secret_key_64}

      error ->
        error
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

  @spec encoded64_keypair({public_key :: String.t(), secret_key :: String.t()}) ::
          {:ok, {String.t(), String.t()}} | {:error, String.t()}
  defp encoded64_keypair({public_key, secret_key}) do
    public_key_64 = Base.encode64(public_key, padding: false)
    secret_key_64 = Base.encode64(secret_key, padding: false)

    {:ok, {public_key_64, secret_key_64}}
  end

  defp encoded64_keypair(_keypair), do: {:error, "Keypair Encode64 error"}
end
