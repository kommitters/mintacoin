defmodule Mintacoin.Crypto.CannedCryptoConsumerImpl do
  @moduledoc """
  This module defines a canned implementation of the crypto module to return mocked responses for testing.
  """

  @behaviour Mintacoin.Crypto.Spec

  alias Mintacoin.Crypto.TxResponse

  @impl true
  def create_account(%{destination: "bad_destination"}) do
    {:error,
     %TxResponse{
       successful: false,
       id: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
       hash: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
       created_at: ~U[2022-06-29 15:45:45Z],
       blockchain: :stellar,
       raw_tx: %{
         hash: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
         id: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
         successful: false
       }
     }}
  end

  def create_account(_account_created_event) do
    {:ok,
     %TxResponse{
       successful: false,
       id: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
       hash: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
       created_at: ~U[2022-06-29 15:45:45Z],
       blockchain: :stellar,
       raw_tx: %{
         hash: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
         id: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
         successful: false
       }
     }}
  end

  @impl true
  def authorize_asset(_asset_authorized_event), do: :ok

  @impl true
  def create_asset(_asset_created_event), do: :ok

  @impl true
  def process_payment(_process_payment_event), do: :ok

  @impl true
  def random_keypair, do: :ok
end

defmodule Mintacoin.Events.ConsumerTest do
  @moduledoc """
  This module defines the test cases for the `Consumer` module.
  """

  use ExUnit.Case

  import Mintacoin.Factory

  alias Mintacoin.{
    Wallet,
    Wallets,
    BlockchainEvent,
    Events.Consumer,
    Crypto.CannedCryptoConsumerImpl
  }

  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)
  end

  describe "create_account/2" do
    setup do
      blockchain = insert(:blockchain, name: "Stellar")

      account = insert(:account)

      %Wallet{address: destination} =
        wallet = insert(:wallet, account: account, blockchain: blockchain)

      blockchain_event =
        insert(:blockchain_event,
          event_type: :create_account,
          event_payload: %{
            balance: 1.5,
            destination: destination
          },
          blockchain: blockchain
        )

      %{
        blockchain_event: blockchain_event,
        wallet: wallet
      }
    end

    test "sucessful create_account pipeline", %{
      blockchain_event: %BlockchainEvent{id: blockchain_event_id} = blockchain_event,
      wallet: %Wallet{address: address}
    } do
      # Check if BlockchainEvent was properly processed
      {:ok,
       %BlockchainEvent{
         id: ^blockchain_event_id,
         successful: true,
         tx_id: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
         tx_hash: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
         tx_response: %{
           created_at: ~U[2022-06-29 15:45:45Z],
           envelope_xdr:
             "AAAAAgAAAAA1g28UW2dCMYtvD0hVfw7+ZM8SjnB/HzQq7lGIRlLuiwAAAGQAAc5vAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAADqwUtg1Z2W2ioK5oidVOy7ezJidLD4oJ6sdOFj6QzNKAAAAAAExLQAAAAAAAAAAAUZS7osAAABAZ8AKJ6GiyYoHUO0wIGcbGe1egu7K1D5K4y50XmF9aRjoD9lxXsIl27Np6k4RJ0h/gqUCxrX2lBY0AhzkzfDjCw==",
           fee_charged: 100,
           fee_meta_xdr:
             "AAAAAgAAAAMAAc5vAAAAAAAAAAA1g28UW2dCMYtvD0hVfw7+ZM8SjnB/HzQq7lGIRlLuiwAAABdIdugAAAHObwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAc9kAAAAAAAAAAA1g28UW2dCMYtvD0hVfw7+ZM8SjnB/HzQq7lGIRlLuiwAAABdIduecAAHObwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==",
           hash: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
           id: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
           ledger: 118_628,
           max_fee: 100,
           memo: nil,
           memo_type: "none",
           operation_count: 1,
           paging_token: "509503380414464",
           result_meta_xdr:
             "AAAAAgAAAAIAAAADAAHPZAAAAAAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAAAXSHbnnAABzm8AAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAHPZAAAAAAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAAAXSHbnnAABzm8AAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAwAAAAAAAc9kAAAAAGK8c6kAAAAAAAAAAQAAAAMAAAADAAHPZAAAAAAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAAAXSHbnnAABzm8AAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAwAAAAAAAc9kAAAAAGK8c6kAAAAAAAAAAQABz2QAAAAAAAAAADWDbxRbZ0Ixi28PSFV/Dv5kzxKOcH8fNCruUYhGUu6LAAAAF0dFupwAAc5vAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAMAAAAAAAHPZAAAAABivHOpAAAAAAAAAAAAAc9kAAAAAAAAAAA6sFLYNWdltoqCuaInVTsu3syYnSw+KCerHThY+kMzSgAAAAABMS0AAAHPZAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAA=",
           result_xdr: "AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=",
           signatures: [
             "Z8AKJ6GiyYoHUO0wIGcbGe1egu7K1D5K4y50XmF9aRjoD9lxXsIl27Np6k4RJ0h/gqUCxrX2lBY0AhzkzfDjCw=="
           ],
           source_account: "GA2YG3YULNTUEMMLN4HUQVL7B37GJTYSRZYH6HZUFLXFDCCGKLXIXMDT",
           source_account_sequence: 508_451_113_402_369,
           successful: true,
           valid_after: nil,
           valid_before: nil
         }
       }} = Consumer.create_account(blockchain_event)

      # Check if Wallet was updated with related blockchain_event_id and settled_in_blockchain
      {:ok,
       %Wallet{
         blockchain_event_id: ^blockchain_event_id,
         settled_in_blockchain: true
       }} = Wallets.retrieve_by_address(address)
    end

    test "create_account pipeline failed", %{blockchain_event: blockchain_event} do
      setup_crypto_canned_impl()

      {:error, :blockchain_transaction_failed} = Consumer.create_account(blockchain_event)
    end

    test "create_account transaction error", %{blockchain_event: blockchain_event} do
      setup_crypto_canned_impl()

      {:error, :blockchain_transaction_error} =
        blockchain_event
        |> Map.put(:event_payload, %{balance: 1.5, destination: "bad_destination"})
        |> Consumer.create_account()
    end

    test "invalid event payload error", %{blockchain_event: blockchain_event} do
      {:error, :invalid_event_payload} =
        blockchain_event
        |> Map.put(:event_payload, %{})
        |> Consumer.create_account()
    end
  end

  defp setup_crypto_canned_impl do
    Application.put_env(:crypto, :impl, CannedCryptoConsumerImpl)

    on_exit(fn ->
      Application.delete_env(:crypto, :impl)
    end)
  end
end
