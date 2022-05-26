defmodule Mintacoin.Encryption.Default do
  @moduledoc false

  @behaviour Mintacoin.Encryption.Spec

  @type public_key() :: String.t()
  @type secret_key() :: String.t()
  @type keypair() :: {public_key(), secret_key()}

  @block_size 16
  @cipher :aes_128_cbc
  @language :english
  @hash_algorithm :sha256
  @key_type :eddsa
  @edwards_curve_ed :ed25519

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

  @impl true
  def random_keypair do
    @key_type
    |> :crypto.generate_key(@edwards_curve_ed)
    |> encode_keypair()
  end

  @impl true
  def public_key_from_secret_key(secret_key) do
    {:ok, secret_key} = Base.hex_decode32(secret_key, padding: false)

    @key_type
    |> :crypto.generate_key(@edwards_curve_ed, secret_key)
    |> encode_keypair()
  rescue
    _error -> {:error, :decoding_error}
  end

  @impl true
  def mnemonic_encrypt(secret_key_64) do
    entropy = generate_secret()
    words = Bip39.get_words(@language)

    seed_words =
      entropy
      |> Base.decode64!(padding: false)
      |> Bip39.entropy_to_mnemonic(words)

    case encrypt(secret_key_64, entropy) do
      {:ok, encrypted_secret} ->
        {:ok, encrypted_secret, seed_words}

      error ->
        error
    end
  end

  @impl true
  def recover_secret_key_from_seed_words(encrypted_secret, seed_words) do
    entropy =
      @language
      |> Bip39.get_words()
      |> (&Bip39.mnemonic_to_entropy(seed_words, &1)).()
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

  @spec encode_keypair(keypair :: keypair()) :: {:ok, keypair()}
  defp encode_keypair({public_key, secret_key}) do
    encoded_public_key = Base.hex_encode32(public_key, padding: false)
    encoded_secret_key = Base.hex_encode32(secret_key, padding: false)

    {:ok, {encoded_public_key, encoded_secret_key}}
  end
end
