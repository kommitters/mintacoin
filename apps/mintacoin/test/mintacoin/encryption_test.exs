defmodule Mintacoin.EncryptionTest do
  @moduledoc """
  This modules defines the test cases of the `Encryption` module.
  """

  use Mintacoin.DataCase

  alias Mintacoin.Encryption

  setup do
    %{
      public_key: "PRI8EQ22VCOV30TGEOVPNAC5KODDO0UCJK0IKUF081DCS22MNU30",
      secret_key: "CLC6HS1QP6OG6MMD2HKS5B53882KBMCUGT91VR7OS0KUGVEKSVM0",
      encrypted_secret_key:
        "GwSF3MyB7gR18R0Jwz3pw4H3drMIlH/j8lbarAA3eLrxholC4H6UUwTZJynbuvhWacg8J9Gzgu0jRbUKEy6lqILDmv+KlG8MiigwDGnPbuU",
      seed_words: [
        "skin",
        "sudden",
        "early",
        "duty",
        "dove",
        "write",
        "chuckle",
        "stove",
        "fossil",
        "material",
        "wire",
        "stool"
      ]
    }
  end

  describe "generate_secret/0" do
    test "should return a secret key" do
      secret = Encryption.generate_secret()
      refute is_nil(secret)
      16 = byte_size(Base.decode64!(secret, padding: false))
    end
  end

  describe "one_time_token/0" do
    test "should return a token" do
      {:ok, token} = Encryption.one_time_token()
      refute is_nil(token)
    end
  end

  describe "encrypt/2" do
    test "with valid secret should return a ciphertext" do
      secret = Encryption.generate_secret()
      {:ok, _ciphertext} = Encryption.encrypt("test", secret)
    end

    test "with invalid secret should return an error" do
      {:error, :encryption_error} = Encryption.encrypt("test", "invalid")
    end
  end

  describe "decrypt/2" do
    test "with valid secret should return a plaintext" do
      secret = Encryption.generate_secret()
      {:ok, ciphertext} = Encryption.encrypt("test", secret)
      {:ok, "test"} = Encryption.decrypt(ciphertext, secret)
    end

    test "with invalid secret should return an error" do
      {:error, :decoding_error} = Encryption.decrypt("test", "invalid")
    end
  end

  describe "random_keypair/0" do
    test "should return a keypair with a public and secret key" do
      {:ok, {public_key, secret_key}} = Encryption.random_keypair()
      refute is_nil(public_key)
      refute is_nil(secret_key)
    end
  end

  describe "pk_from_sk/1" do
    test "with a valid secret key, it should return the keypair with the right public key", %{
      public_key: pk,
      secret_key: sk
    } do
      {:ok, {^pk, ^sk}} = Encryption.pk_from_sk(sk)
    end

    test "with an invalid secret key, it should return an error" do
      {:error, :decoding_error} = Encryption.pk_from_sk("invalid")
    end
  end

  describe "seed_words_from_sk/1" do
    test "should return the encrypted_secret and seed words", %{secret_key: sk} do
      {:ok, encrypted_secret, seed_words} = Encryption.seed_words_from_sk(sk)

      refute is_nil(encrypted_secret)
      12 = Enum.count(seed_words)
    end
  end

  describe "sk_from_seed_words/2" do
    test "should return the secret key", %{
      secret_key: sk,
      encrypted_secret_key: encrypted_secret_key,
      seed_words: seed_words
    } do
      {:ok, ^sk} = Encryption.sk_from_seed_words(encrypted_secret_key, seed_words)
    end
  end
end
