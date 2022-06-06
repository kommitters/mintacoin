defmodule Mintacoin.Encryption.DefaultTest do
  @moduledoc """
  This modules defines the test cases of the `Encryption.Default` module.
  """

  use Mintacoin.DataCase

  alias Mintacoin.Encryption

  describe "generate_secret/0" do
    test "should return a secret" do
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
    test "with valid secret of 32 bytes should return a ciphertext" do
      secret = Encryption.generate_secret(bytes: 32)
      {:ok, _ciphertext} = Encryption.encrypt("test", secret)
    end

    test "with valid secret of 16 bytes should return a ciphertext" do
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
end
