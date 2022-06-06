defmodule Mintacoin.Encryption.CannedEncryptionImpl do
  @moduledoc false

  @behaviour Mintacoin.Encryption.Spec

  @impl true
  def generate_secret(_opts) do
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
  def one_time_token(_opts) do
    send(self(), {:one_time_token, "API_TOKEN"})
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

  test "one_time_token/0" do
    Mintacoin.Encryption.one_time_token()
    assert_receive({:one_time_token, "API_TOKEN"})
  end
end
