defmodule Mintacoin.Crypto.StellarTest do
  use ExUnit.Case

  alias Mintacoin.{Crypto, Crypto.TxResponse}

  test "create_account/1" do
    {:ok, %TxResponse{}} = Crypto.create_account(%{})
  end

  test "create_asset/1" do
    {:ok, %TxResponse{}} = Crypto.create_asset(%{})
  end

  test "authorize_asset/1" do
    {:ok, %TxResponse{}} = Crypto.authorize_asset(%{})
  end

  test "process_payment/1" do
    {:ok, %TxResponse{}} = Crypto.process_payment(%{})
  end
end
