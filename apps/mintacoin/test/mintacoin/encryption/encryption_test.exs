defmodule Mintacoin.Encryption.CannedEncryptionImpl do
  @moduledoc false

  @behaviour Mintacoin.Encryption.Spec

  @impl true
  def generate_secret do
    send(self(), {:generate_secret, "SECRET"})
    :ok
  end

  @impl true
  def encrypt(_payload, _key) do
    send(self(), {:encrypt, "CIPHERTEXT"})
    :ok
  end

  @impl true
  def decrypt(_ciphertext, _key) do
    send(self(), {:decrypt, "PLAIN_TEXT"})
    :ok
  end

  @impl true
  def random_keypair do
    send(self(), {:random_keypair, "KEYPAIR"})
    :ok
  end

  @impl true
  def public_key_from_secret_key(_secret_key) do
    send(self(), {:public_key_from_secret_key, "KEYPAIR"})
    :ok
  end

  @impl true
  def one_time_token do
    send(self(), {:one_time_token, "API_TOKEN"})
    :ok
  end

  @impl true
  def mnemonic_encrypt(_secret_key) do
    send(self(), {:mnemonic_encrypt, "SEED_WORDS"})
    :ok
  end

  @impl true
  def recover_secret_key_from_seed_words(_encrypted_secret, _seed_words) do
    send(self(), {:recover_secret_key_from_seed_words, "SECRET_KEY"})
    :ok
  end
end

defmodule Mintacoin.EncryptionTest do
  use ExUnit.Case

  alias Mintacoin.Encryption.CannedEncryptionImpl

  setup do
    Application.put_env(:encryption, :impl, CannedEncryptionImpl)

    on_exit(fn ->
      Application.delete_env(:encryption, :impl)
    end)
  end

  test "generate_secret/0" do
    Mintacoin.Encryption.generate_secret()
    assert_receive({:generate_secret, "SECRET"})
  end

  test "encrypt/2" do
    Mintacoin.Encryption.encrypt("PLAIN_TEXT", "SECRET")
    assert_receive({:encrypt, "CIPHERTEXT"})
  end

  test "decrypt/2" do
    Mintacoin.Encryption.decrypt("CIPHERTEXT", "SECRET")
    assert_receive({:decrypt, "PLAIN_TEXT"})
  end

  test "random_keypair/0" do
    Mintacoin.Encryption.random_keypair()
    assert_receive({:random_keypair, "KEYPAIR"})
  end

  test "public_key_from_secret_key/1" do
    Mintacoin.Encryption.public_key_from_secret_key("PUBLIC_KEY")
    assert_receive({:public_key_from_secret_key, "KEYPAIR"})
  end

  test "one_time_token/0" do
    Mintacoin.Encryption.one_time_token()
    assert_receive({:one_time_token, "API_TOKEN"})
  end

  test "mnemonic_encrypt/1" do
    Mintacoin.Encryption.mnemonic_encrypt("SECRET_KEY")
    assert_receive({:mnemonic_encrypt, "SEED_WORDS"})
  end

  test "recover_secret_key_from_seed_words/2" do
    Mintacoin.Encryption.recover_secret_key_from_seed_words("ENCRYPTED_SECRET", "SEED_WORDS")
    assert_receive({:recover_secret_key_from_seed_words, "SECRET_KEY"})
  end
end
