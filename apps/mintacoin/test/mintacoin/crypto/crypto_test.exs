defmodule Mintacoin.Crypto.CannedCryptoImpl do
  @moduledoc false

  @behaviour Mintacoin.Crypto.Spec

  @impl true
  def create_account(_params) do
    send(self(), {:create_account, "ACCOUNT"})
    :ok
  end

  @impl true
  def create_asset(_params) do
    send(self(), {:create_asset, "ASSET"})
    :ok
  end

  @impl true
  def authorize_asset(_params) do
    send(self(), {:authorize_asset, "ASSET"})
    :ok
  end

  @impl true
  def process_payment(_params) do
    send(self(), {:process_payment, "PAYMENT"})
    :ok
  end
end

defmodule Mintacoin.CryptoTest do
  use ExUnit.Case

  alias Mintacoin.{Crypto, Crypto.CannedCryptoImpl}

  setup do
    Application.put_env(:crypto, :impl, CannedCryptoImpl)

    on_exit(fn ->
      Application.delete_env(:crypto, :impl)
    end)
  end

  test "create_account/1" do
    Crypto.create_account(%{})
    assert_receive({:create_account, "ACCOUNT"})
  end

  test "create_asset/1" do
    Crypto.create_asset(%{})
    assert_receive({:create_asset, "ASSET"})
  end

  test "authorize_asset/1" do
    Crypto.authorize_asset(%{})
    assert_receive({:authorize_asset, "ASSET"})
  end

  test "process_payment/1" do
    Crypto.process_payment(%{})
    assert_receive({:process_payment, "PAYMENT"})
  end
end
