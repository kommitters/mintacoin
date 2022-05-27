defmodule Mintacoin.Keypair.DefaultTest do
  @moduledoc """
  This modules defines the test cases of the `Keypair.Default` default module.
  """

  use Mintacoin.DataCase

  alias Mintacoin.Keypair

  setup do
    %{
      public_key: "30MGLHU1OGC23O06RFSHSA5325O49V05UEFA81FMN8JHV0AUVKG0",
      secret_key: "0Qmk3ZinGhZLuIMJC2j/WNN+scV3MMLxkI5ALlAVun8"
    }
  end

  describe "random/0" do
    test "should return a keypair with a public and secret key" do
      {:ok, {public_key, secret_key}} = Keypair.random()
      refute is_nil(public_key)
      refute is_nil(secret_key)
    end
  end

  describe "from_secret_key/1" do
    test "with a valid secret key, it should return the keypair with the right public key", %{
      public_key: pk,
      secret_key: sk
    } do
      {:ok, {^pk, ^sk}} = Keypair.from_secret_key(sk)
    end

    test "with an invalid secret key, it should return an error" do
      {:error, :secret_key_error} = Keypair.from_secret_key("invalid")
    end
  end
end
