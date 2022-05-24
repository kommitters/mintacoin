defmodule Mintacoin.EncrypterTest do
  @moduledoc """
  This modules defines the test cases of the `Encrypter` module.
  """

  use Mintacoin.DataCase

  alias Mintacoin.Encrypter

  describe "generate_secret/0" do
    test "should return a secret key" do
      refute is_nil(Encrypter.generate_secret())
    end
  end

  describe "one_time_token/0" do
    test "Should return the encoded, and the hashed token" do
      {:ok, {encoded_token, hashed_token}} = Encrypter.one_time_token()

      ^hashed_token =
        encoded_token
        |> Base.decode64!(padding: false)
        |> (&:crypto.hash(:sha256, &1)).()
        |> Base.encode64(padding: false)
    end
  end

  describe "encrypt/2" do
    test "with valid secret should return a ciphertext" do
      secret = Encrypter.generate_secret()
      {:ok, _ciphertext} = Encrypter.encrypt("test", secret)
    end

    test "with invalid secret should return an error" do
      {:error, error} = Encrypter.encrypt("test", "invalid")
      "Decode64 error" = error
    end
  end

  describe "decrypt/2" do
    test "with valid secret should return a plaintext" do
      secret = Encrypter.generate_secret()
      {:ok, ciphertext} = Encrypter.encrypt("test", secret)
      {:ok, plaintext} = Encrypter.decrypt(ciphertext, secret)
      "test" = plaintext
    end

    test "with invalid secret should return an error" do
      {:error, error} = Encrypter.decrypt("test", "invalid")
      "Pattern matching error while decoding ciphertext" = error
    end
  end

  describe "random_keypair/0" do
    test "should return a keypair with a public and secret key" do
      {:ok, {public_key, secret_key}} = Encrypter.random_keypair()
      refute is_nil(public_key)
      refute is_nil(secret_key)
    end
  end

  describe "pk_from_sk/1" do
    test "with a valid secret key, it should return the keypair with the right public key" do
      {:ok, {pk, sk}} = Encrypter.random_keypair()
      {:ok, {assumed_pk, assumed_sk}} = Encrypter.pk_from_sk(sk)
      # Public key should match
      ^pk = assumed_pk
      # Secret key should be the same as the given one
      ^sk = assumed_sk
    end

    test "with an invalid secret key, it should return an error" do
      {:error, error} = Encrypter.pk_from_sk("invalid")
      "Decode64 error" = error
    end
  end

  describe "seed_words_from_sk/1" do
    test "should return the encrypted_secret and seed words" do
      {:ok, {_pk, sk}} = Encrypter.random_keypair()
      {:ok, encrypted_secret, seed_words} = Encrypter.seed_words_from_sk(sk)

      refute is_nil(encrypted_secret)
      12 = Enum.count(seed_words)
    end
  end

  describe "sk_from_seed_words/2" do
    test "should return the secret key" do
      {:ok, {_pk, sk}} = Encrypter.random_keypair()
      {:ok, encrypted_secret, seed_words} = Encrypter.seed_words_from_sk(sk)
      # Recovered secret key should match
      {:ok, ^sk} = Encrypter.sk_from_seed_words(encrypted_secret, seed_words)
    end
  end
end
