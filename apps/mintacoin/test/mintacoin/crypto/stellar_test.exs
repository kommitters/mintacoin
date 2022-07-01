defmodule Mintacoin.Crypto.StellarTest do
  use ExUnit.Case

  alias Mintacoin.Crypto
  alias Mintacoin.Crypto.{AccountCreated, AssetCreated, AssetAuthorized, PaymentCreated}

  test "create_account/1" do
    {:ok, %AccountCreated{}} = Crypto.create_account(%{})
  end

  test "create_asset/1" do
    {:ok, %AssetCreated{}} = Crypto.create_asset(%{})
  end

  test "authorize_asset/1" do
    {:ok, %AssetAuthorized{}} = Crypto.authorize_asset(%{})
  end

  test "process_payment/1" do
    {:ok, %PaymentCreated{}} = Crypto.process_payment(%{})
  end
end
