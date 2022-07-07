defmodule Mintacoin.Wallets.WalletsTest do
  @moduledoc """
    This module is used to group common tests for Wallets functions
  """

  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory

  alias Mintacoin.{
    Repo,
    Wallet,
    Wallets,
    Account,
    Blockchain,
    Blockchains,
    Blockchains.Network,
    BlockchainEvent
  }

  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)

    {:ok, %Blockchain{id: blockchain_id} = blockchain} =
      Blockchains.create(%{name: Network.name()})

    %Account{id: account_id} = insert(:account, email: "account@mail.com", name: "Account name")

    %{
      wallet: %{
        address: "KUU65DG3NREN84RV39LS7J3E6GKTR82BV6L7QO88TU9I2QIOE2AG",
        encrypted_secret: "x4lUNWS/MHHbvhNvDfydziBlxFB6/5vQnK5ekmnDzgo",
        blockchain_id: blockchain_id,
        account_id: account_id
      },
      blockchain: blockchain,
      invalid_id: "1",
      non_existing_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203146"
    }
  end

  describe "create/1" do
    test "with valid params", %{
      wallet:
        %{
          address: address,
          encrypted_secret: encrypted_secret,
          blockchain_id: blockchain_id,
          account_id: account_id
        } = wallet_data
    } do
      {:ok,
       %Wallet{
         address: ^address,
         encrypted_secret: ^encrypted_secret,
         blockchain_id: ^blockchain_id,
         account_id: ^account_id
       }} = Wallets.create(wallet_data)
    end

    test "with invalid params" do
      {:error, changeset} = Wallets.create(%{})

      %{
        address: ["can't be blank"],
        encrypted_secret: ["can't be blank"],
        account_id: ["can't be blank"],
        blockchain_id: ["can't be blank"]
      } = errors_on(changeset)
    end
  end

  describe "retrieve/1" do
    setup %{wallet: wallet_data} do
      {:ok, wallet} = Wallets.create(wallet_data)

      %{
        wallet: wallet,
        invalid_id: "1"
      }
    end

    test "with valid id", %{wallet: %Wallet{id: id}} do
      {:ok, %Wallet{id: ^id}} = Wallets.retrieve(id)
    end

    test "with invalid id", %{invalid_id: id} do
      {:error, :not_found} = Wallets.retrieve(id)
    end
  end

  describe "retrieve_by_address/1" do
    setup %{wallet: wallet_data} do
      {:ok, wallet} = Wallets.create(wallet_data)

      %{wallet: wallet, invalid_address: "invalid_address"}
    end

    test "with valid address", %{wallet: %Wallet{address: address}} do
      {:ok, %Wallet{address: ^address}} = Wallets.retrieve_by_address(address)
    end

    test "with invalid address", %{invalid_address: invalid_address} do
      {:error, :not_found} = Wallets.retrieve_by_address(invalid_address)
    end
  end

  describe "retrieve_by_account_and_blockchain/2" do
    setup %{wallet: wallet_data} do
      {:ok, wallet} = Wallets.create(wallet_data)

      %{
        wallet: wallet,
        non_existing_account_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203147",
        non_existing_blockchain_id: "77d50348-5991-4981-957a-b0b9e52b12fb"
      }
    end

    test "with valid account_id and blockchain_id", %{
      wallet: %Wallet{account_id: account_id, blockchain_id: blockchain_id}
    } do
      {:ok, %Wallet{account_id: ^account_id, blockchain_id: ^blockchain_id}} =
        Wallets.retrieve_by_account_and_blockchain(account_id, blockchain_id)
    end

    test "with invalid account_id and blockchain_id", %{
      non_existing_account_id: non_existing_account_id,
      non_existing_blockchain_id: non_existing_blockchain_id
    } do
      {:error, :not_found} =
        Wallets.retrieve_by_account_and_blockchain(
          non_existing_account_id,
          non_existing_blockchain_id
        )
    end
  end

  describe "retrieve_by/1" do
    setup %{wallet: wallet_data} do
      {:ok, wallet} = Wallets.create(wallet_data)

      %{wallet: wallet}
    end

    test "with valid params, return wallet", %{wallet: %Wallet{blockchain_id: blockchain_id}} do
      {:ok, %Wallet{blockchain_id: ^blockchain_id}} =
        Wallets.retrieve_by(blockchain_id: blockchain_id)
    end

    test "with not valid params, return not found error" do
      {:error, :not_found} = Wallets.retrieve_by(address: "address")
    end

    test "with bad argument" do
      {:error, :bad_argument} = Wallets.retrieve_by("invalid")
    end
  end

  describe "update/1" do
    setup %{blockchain: blockchain} do
      %BlockchainEvent{id: blockchain_event_id} =
        insert(:blockchain_event, blockchain: blockchain)

      %{
        wallet: insert(:wallet, blockchain: blockchain),
        valid_attrs: %{
          settled_in_blockchain: true,
          blockchain_event_id: blockchain_event_id
        },
        invalid_attrs: %{
          settled_in_blockchain: "invalid_value",
          blockchain_event_id: "invalid_id"
        }
      }
    end

    test "with invalid id", %{invalid_id: id, valid_attrs: valid_attrs} do
      {:error, :not_found} = Wallets.update(id, valid_attrs)
    end

    test "with non existing id", %{non_existing_id: id, valid_attrs: valid_attrs} do
      {:error, :not_found} = Wallets.update(id, valid_attrs)
    end

    test "with invalid params", %{wallet: %Wallet{id: id}, invalid_attrs: invalid_attrs} do
      {:error, changeset} = Wallets.update(id, invalid_attrs)

      %{
        settled_in_blockchain: ["is invalid"],
        blockchain_event_id: ["blockchain_event_id must be a uuid"]
      } = errors_on(changeset)
    end

    test "with valid params", %{
      wallet: %Wallet{id: id},
      valid_attrs: %{blockchain_event_id: blockchain_event_id} = valid_attrs
    } do
      {:ok, %Wallet{settled_in_blockchain: true, blockchain_event_id: ^blockchain_event_id}} =
        Wallets.update(id, valid_attrs)
    end

    test "only changing the settled_in_blockchain param", %{
      wallet: %Wallet{id: id}
    } do
      {:ok, %Wallet{settled_in_blockchain: true}} =
        Wallets.update(id, %{settled_in_blockchain: true})
    end
  end
end
